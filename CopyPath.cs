using System;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Text;
using System.Threading;

// Windows inbox .NET Framework only. No OLE, file/network IO, or resident process.
internal static class CopyPath
{
    private const uint UnicodeText = 13;
    private const uint Moveable = 2;
    private const int BusyTimeoutMs = 1500;

    private static int Main(string[] args)
    {
        // The suffix keeps a root/trailing backslash from escaping the closing
        // quote in Explorer's command line. '|' cannot occur in a Windows path.
        if (args.Length != 1 || !args[0].EndsWith("|", StringComparison.Ordinal))
            return 1;
        string path = args[0].Substring(0, args[0].Length - 1);
        if (path.Length == 0 || path.IndexOfAny(new[] { '\0', '|', '"' }) >= 0)
            return 1;

        IntPtr memory = IntPtr.Zero;
        IntPtr owner = IntPtr.Zero;
        bool opened = false;
        try
        {
            byte[] bytes = Encoding.Unicode.GetBytes(path + '\0');
            memory = GlobalAlloc(Moveable, new UIntPtr((uint)bytes.Length));
            if (memory == IntPtr.Zero) return 2;
            IntPtr data = GlobalLock(memory);
            if (data == IntPtr.Zero) return 2;
            try { Marshal.Copy(bytes, 0, data, bytes.Length); }
            finally { GlobalUnlock(memory); }

            // A hidden message-only window is the clipboard owner. Never open
            // with NULL before EmptyClipboard / SetClipboardData.
            owner = CreateWindowExW(0, "STATIC", "CopyPath", 0, 0, 0, 0, 0,
                new IntPtr(-3), IntPtr.Zero, IntPtr.Zero, IntPtr.Zero);
            if (owner == IntPtr.Zero) return 2;

            Stopwatch timer = Stopwatch.StartNew();
            while (!(opened = OpenClipboard(owner)))
            {
                if (timer.ElapsedMilliseconds >= BusyTimeoutMs)
                    return 3; // Leave existing clipboard content untouched.
                Thread.Sleep(15);
            }

            if (!EmptyClipboard()) return 2;
            if (SetClipboardData(UnicodeText, memory) == IntPtr.Zero) return 2;
            memory = IntPtr.Zero; // Windows owns the fully materialized text.
            return 0;
        }
        catch { return 2; }
        finally
        {
            if (opened) CloseClipboard();
            if (owner != IntPtr.Zero) DestroyWindow(owner);
            if (memory != IntPtr.Zero) GlobalFree(memory);
        }
    }

    [DllImport("user32.dll", ExactSpelling = true, CharSet = CharSet.Unicode)]
    private static extern IntPtr CreateWindowExW(uint exStyle, string className,
        string name, uint style, int x, int y, int width, int height,
        IntPtr parent, IntPtr menu, IntPtr instance, IntPtr parameter);
    [DllImport("user32.dll")]
    private static extern bool DestroyWindow(IntPtr window);
    [DllImport("user32.dll")]
    private static extern bool OpenClipboard(IntPtr owner);
    [DllImport("user32.dll")]
    private static extern bool CloseClipboard();
    [DllImport("user32.dll")]
    private static extern bool EmptyClipboard();
    [DllImport("user32.dll")]
    private static extern IntPtr SetClipboardData(uint format, IntPtr memory);
    [DllImport("kernel32.dll")]
    private static extern IntPtr GlobalAlloc(uint flags, UIntPtr bytes);
    [DllImport("kernel32.dll")]
    private static extern IntPtr GlobalLock(IntPtr memory);
    [DllImport("kernel32.dll")]
    private static extern bool GlobalUnlock(IntPtr memory);
    [DllImport("kernel32.dll")]
    private static extern IntPtr GlobalFree(IntPtr memory);
}
