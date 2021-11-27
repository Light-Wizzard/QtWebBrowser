# QtWebBrowser

This Web Browser is based off of the Qt 5.15 example of Simple Browser,
that example and documentation can be found here: https://doc.qt.io/qt-5/qtwebengine-webenginewidgets-simplebrowser-example.html


I am trying to make this app work without popup dialog, 
the first dialog box I need to replace is the Downloads Dialog box, 
I want this to open in a tab.

This is just an example of how to accomplish this.

What I leaned from the Qt Forum:
https://forum.qt.io/topic/132339/how-do-you-keep-a-class-from-deleting-an-argument-passed-in-by-reference

I need to use a QPointer, 
I could not use a QSharedPointer point due to needing to set Attributes

```c
myDownloadManagerWidget->setAttribute(Qt::WA_QuitOnClose, false);
```

If you run this app and click on the download button, 
it will open in a Tab and not a popup dialog box.

