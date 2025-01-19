
## Standardized verbs
# configure- = configure something that is pre-installed on the image
# install-   = install something, no uninstall or configuration provided
# setup-     = install something and also provide configuration and/or uninstallation options
# toggle-    = turn something on/off, logic can be automatic or manual selection
# fix-       = apply fix/patch/workaround for something
# foo        = no verb is used for shortcuts or something deemed important enough to use a super memorable name

[group('Apps')]
configure-palemoon:
    echo "Opening Pale Moon to install Netscape theme"
    palemoon "https://addons.palemoon.org/addon/moonscape/" >/dev/null 2>&1 &

[group('Apps')]
configure-audacious:
    mkdir -p ~/.var/app/org.atheme.audacious/data/audacious/Skins
    cd ~/.var/app/org.atheme.audacious/data/audacious/Skins
    mkdir Winamp
    cd Winamp
    wget https://archive.org/download/winampskin_Winamp_Classic_CM/Winamp_Classic_CM.wsz
    unzip *.wsz && rm *.wsz

