# QtWebBrowser

This Web Browser is based off of the Qt 5.15 example of Simple Browser,
that example and documentation can be found here: https://doc.qt.io/qt-5/qtwebengine-webenginewidgets-simplebrowser-example.html


I am trying to bet this app to work without popup dialog, 
the first dialog box I need to replace is the Downloads Dialog box, 
I want this to open in a tab,
my problem is it crashes on exit,
this has something to do with the way I am trying to accomplish the tab task,
it takes the address to the Downloads Manager, 
this causes the Tab Widget to hold on to that address,
and due to the order things are getting deleted,
the value is already deleted,
causing the crash.

If you look at BrowserWindow constructor you will see where I call onDownloadTab(),
I use two variable defined in the TabWidget class

```c
DownloadManagerWidget *myDownloadManagerWidget = nullptr;
int m_DownloadTab = -1;
```

I added to functions to TabWidget:

```c
void TabWidget::createDownloadTab(DownloadManagerWidget *thisDownloadManagerWidget)
{
   if (m_DownloadTab == -1)
   {
       myDownloadManagerWidget = thisDownloadManagerWidget;
       setUpdatesEnabled(false);
       m_DownloadTab = addTab(myDownloadManagerWidget, tr("Downloads"));
       setTabIcon(m_DownloadTab, QIcon());
       setTabVisible(m_DownloadTab, false);
       // Workaround for QTBUG-61770
       myDownloadManagerWidget->resize(currentWidget()->size());
       setCurrentWidget(myDownloadManagerWidget);
       setUpdatesEnabled(true);
   }
   else
   {
       if (!isTabVisible(m_DownloadTab))
       {
           setTabVisible(m_DownloadTab, true);
       }
       setCurrentIndex(m_DownloadTab);
   }
}

int TabWidget::getDownloadTab()
{
   return m_DownloadTab;
}
```

In QToolBar *BrowserWindow::createToolBar(),
I changed:

```c
connect(downloadsAction, &QAction::triggered, [this]() { m_browser->downloadManagerWidget().show(); });

to this

connect(downloadsAction, &QAction::triggered, this, &BrowserWindow::onDownloadTab);
```

The onDownloadTab looks like this:

```c
void BrowserWindow::onDownloadTab()
{
   if (m_tabWidget->getDownloadTab() == -1)
   {
       m_tabWidget->createDownloadTab(&m_browser->downloadManagerWidget());
   }
   else
   {
       m_tabWidget->setCurrentIndex(m_tabWidget->getDownloadTab());
       if (!m_tabWidget->isTabVisible(m_tabWidget->getDownloadTab()))
       {
           m_tabWidget->setTabVisible(m_tabWidget->getDownloadTab(), true);
       }
   }
}
```

The first time its called the DownloadTab == -1,
this causes it to create the Tab,
seen above in createDownloadTab,
I have tried various code changes around this code:

```c
myDownloadManagerWidget = thisDownloadManagerWidget;
```

I cannot delete, and setting it to null does nothing to decouple it.

I have tried to use the deconstructor with no help.

This app creates the Tab once and hides it on close, so the tab is always open, 
I have tried to close all tabs with no help.

I am going to add Bookmarks to this app, and want everything to be a tab,
I have the bookmarks working in an another app,
but need to make a bare as possible version of this app to troubleshoot this one issue.

I have no idea how to fix this issue at this,
I have thought about refactoring the DownloadManagerWidget,
but not sure what I need to change to make this work,
and it works now and I do not want that to break.

If you download the code and run it in debug in Qt Creator or from a terminal, 
you will see the crash:

```
js: UF: Pollyfill not needed, skipping.
free(): invalid pointer
Aborted (core dumped)
```

I am not sure what pointer is invalid, 
I am assuming it is the myDownloadManagerWidget

```c
private:
DownloadManagerWidget *myDownloadManagerWidget = nullptr;

myDownloadManagerWidget = thisDownloadManagerWidget;
```

I have tired to move the scope of this, 
but really the scope should be with the TabWidget,
since its holding this pointer in the tab.

I have tried to set the setCurrentWidget(nullptr),
even change the icon with no help.

If I removeTab, Qt does not delete the Widget,
only the Tab,
then you have a dangling widget,
and why I defined it as private with the widget,
so I could handle its life-cycle,
my thought was I could create a new tab with that context,
it had no effect,
so I left it like I think it should be,
and just hide the tab instead of removing it,
so I stored its tab number for a reference.

I am going to add many more tabs, 
in my main app called WeBookClient https://github.com/Light-Wizzard/WeBookClient,
you will find this same project with working Bookmarks,
as well as the Help or About button is now a Tab,
and these work without any issues,
so I assume the way I am doing this is correct,
I have handle the object differently since it has been created by main window aka BrowserWindow,
and moving the ownership there did not help,
but this is the way I will leave it:

```c
void TabWidget::createDownloadTab(DownloadManagerWidget *thisDownloadManagerWidget)
{
   if (m_DownloadTab == -1)
   {
       setUpdatesEnabled(false);
       m_DownloadTab = addTab(thisDownloadManagerWidget, tr("Downloads"));
       setTabIcon(m_DownloadTab, QIcon());
       setTabVisible(m_DownloadTab, false);
       // Workaround for QTBUG-61770
       thisDownloadManagerWidget->resize(currentWidget()->size());
       setCurrentWidget(thisDownloadManagerWidget);
       setUpdatesEnabled(true);
   }
   else
   {
       if (!isTabVisible(m_DownloadTab))
       {
           setTabVisible(m_DownloadTab, true);
       }
       setCurrentIndex(m_DownloadTab);
   }
}
```

I started off with this code and added the variable in TabWidget to try to change the deletion order.

You can see I even changed the icon thinking maybe its that point:

```c
setTabIcon(m_DownloadTab, QIcon());

```

Looking at the debugger compiler it showed this crashes during a call to int_free,
that internally takes arguments like this:


```
static void _int_free (mstate av, mchunkptr p, int have_lock)

```

if is doing a mov 

```
mov    %ebp,%fs:(%rbx)

with these pointers

64 89 2b

```

I assume that issues is with mchunkptr,
tracing this back, 
I find the main problem,
TabWidget is deleting the pointer to DownloadManagerWidget that is private to BrowserWindow:

```c
DownloadManagerWidget *myDownloadManagerWidget = nullptr;
```

This should only be deleted by BrowserWindow,
and in facts looks to be deleted already,
and why this is crashing.

My question is how do I keep TabWidget from trying to delete this.
