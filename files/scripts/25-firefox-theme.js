// skip 1st line
try {
  const ds = Cc['@mozilla.org/file/directory_service;1'].getService(Ci.nsIProperties);
  const profileDir = ds.get('ProfD', Ci.nsIFile);

  const chromeDir = profileDir.clone();
  chromeDir.append('chrome');
  const utilsDir = chromeDir.clone();
  utilsDir.append('utils');

  // Blue95: bootstrap win95 theme on first launch by copying from the
  // system-provided template at browser/defaults/profile/chrome/.
  // fx-autoconfig alone can't do this because boot.sys.mjs only runs
  // after chrome/utils/chrome.manifest already exists.
  if (!utilsDir.exists()) {
    const template = Cc['@mozilla.org/file/local;1'].createInstance(Ci.nsIFile);
    template.initWithPath('/usr/lib64/firefox/browser/defaults/profile/chrome');
    if (template.exists()) {
      try {
        if (!chromeDir.exists()) {
          template.copyTo(profileDir, 'chrome');
        } else {
          // chrome/ exists (e.g. user has userChrome.css) — merge in our files
          const entries = template.directoryEntries;
          while (entries.hasMoreElements()) {
            const entry = entries.getNext().QueryInterface(Ci.nsIFile);
            const dest = chromeDir.clone();
            dest.append(entry.leafName);
            if (!dest.exists()) {
              entry.copyTo(chromeDir, entry.leafName);
            }
          }
        }
      } catch(copyErr) {}
    }
  }

  // fx-autoconfig: register chrome manifest and load the userscript boot loader
  const cmanifest = utilsDir.clone();
  cmanifest.append('chrome.manifest');

  if (cmanifest.exists()) {
    Components.manager.QueryInterface(Ci.nsIComponentRegistrar).autoRegister(cmanifest);
    ChromeUtils.importESModule('chrome://userchromejs/content/boot.sys.mjs');
  }

} catch(ex) {};
