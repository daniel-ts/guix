(use-modules (gnu)
             (gnu home)
             (gnu packages)
             (gnu home services)
             (gnu home services shells)
             (gnu home services desktop)
             (gnu home services fontutils)
             (gnu services shepherd)
             (gnu home services shepherd)
             (gnu services)
             ;; (guix records) ;; for make
             (gnu packages ssh)
             (gnu packages emacs)
             (gnu services)
             (guix gexp)
             (shepherd support))

(use-package-modules terminals shells mpd dunst gnupg)
;; (use-service-modules audio)

(define my-base-packages (map specification->package
                              '("adwaita-icon-theme" "btrfs-progs" "cmake" "cpupower" "cryptsetup" "cups" "curl" "docker" "emacs-guix" "emacs-next-pgtk" "flatpak" "foomatic-filters" "fzf" "gcc" "ghostscript" "git" "gnupg" "guile-colorized" "hicolor-icon-theme" "hplip" "htop" "icecat" "icedove" "ijs" "jq" "kitty" "libappindicator" "lxd" "make" "meson" "mpd" "mpd-mpc" "nano" "neovim" "network-manager" "network-manager-applet" "network-manager-openvpn" "nss-certs" "ntfs-3g" "ntp" "openjdk" "openntpd" "openssh" "pipewire"  "rsync" "sane-backends"  "splix" "stow" "tree" "wget" "wireguard-tools" "wireplumber" "zsh"  "pinentry-tty" "pinentry" "gcc-toolchain" "qtkeychain" "openssl@1.1.1l" "texlive@20210325" "python" "pkg-config" "sqlite" "nmap" "zstd")))

(define my-base-fonts (map specification->package
                           '("font-adobe-source-code-pro" "font-adobe-source-han-sans" "font-adobe-source-sans-pro" "font-adobe-source-serif-pro" "font-adobe100dpi" "font-adobe75dpi" "font-anonymous-pro" "font-anonymous-pro-minus" "font-awesome" "font-bitstream-vera" "font-blackfoundry-inria" "font-cns11643" "font-cns11643-swjz" "font-comic-neue" "font-cronyx-cyrillic" "font-culmus" "font-dec-misc" "font-dejavu" "font-dosis" "font-dseg" "font-fantasque-sans" "font-fira-code" "font-fira-mono" "font-fira-sans" "font-fontna-yasashisa-antique" "font-gnu-freefont" "font-gnu-unifont" "font-go" "font-google-material-design-icons" "font-google-noto" "font-google-roboto" "font-hack" "font-hermit" "font-ibm-plex" "font-inconsolata" "font-iosevka" "font-iosevka-aile" "font-iosevka-etoile" "font-iosevka-slab" "font-iosevka-term" "font-iosevka-term-slab" "font-ipa-mj-mincho" "font-isas-misc" "font-jetbrains-mono" "font-lato" "font-liberation" "font-linuxlibertine" "font-lohit" "font-meera-inimai" "font-micro-misc" "font-misc-cyrillic" "font-misc-ethiopic" "font-misc-misc" "font-mononoki" "font-mplus-testflight" "font-mutt-misc" "font-opendyslexic" "font-public-sans" "font-rachana" "font-sarasa-gothic" "font-schumacher-misc" "font-screen-cyrillic" "font-sil-andika" "font-sil-charis" "font-sil-gentium" "font-sony-misc" "font-sun-misc" "font-tamzen" "font-terminus" "font-tex-gyre" "font-un" "font-util" "font-vazir" "font-winitzki-cyrillic" "font-wqy-microhei" "font-wqy-zenhei" "font-xfree86-type1")))

(define my-desktop-packages
  (map specification->package
       '("firefox-wayland" "redshift-wayland" "rofi-wayland" "sway" "sway" "swaybg" "swayidle" "waybar" "wl-clipboard" "xorg-server-xwayland" "dunst" "shared-mime-info" "nautilus" "telegram-desktop" "ungoogled-chromium-wayland" "pavucontrol" "seahorse" "qtbase" "qtwayland" "qtwebsockets" "qtsvg" "qtdeclarative" "qtquickcontrols2"  "qtwebengine" "karchive" "xdg-desktop-portal" "xdg-desktop-portal-wlr" "xdg-desktop-portal-gtk" "grim" "evince" "flameshot")))

(define zlogin-contents "
  if [ -z $DISPLAY ] && [ \"$(tty)\" = '/dev/tty1' ]; then
      SDL_VIDEODRIVER=wayland
      export MOZ_ENABLE_WAYLAND=1
      export QT_QPA_PLATFORM='wayland;xcb'
      export XDG_CURRENT_DESKTOP=sway
      export XDG_SESSION_DESKTOP=sway
      export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
      export _JAVA_AWT_WM_NONREPARENTING=1
      exec sway
  fi")

(home-environment
 (packages (append my-base-packages
                   my-base-fonts
                   my-desktop-packages))

 (services
  (list
   (simple-service 'some-useful-env-vars-service
                   home-environment-variables-service-type
                   `(("CMAKE_C_COMPILER" . "gcc")
                     ("GUILE_AUTO_COMPILE" . "0")
                     ("ALTERNATE_EDITOR" . "emacs -Q")
                     ("EDITOR" . "emacsclient --create-frame")
                     ("VISUAL" . "emacsclient --create-frame")
                     ("GUIX_PROFILE" . "$HOME/.guix-profile")
                     ("XDG_DOCUMENTS_DIR" . "$HOME/docs")
                     ("XDG_DOWNLOADS_DIR" . "$HOME/downloads")
                     ("XDG_DOWNLOAD_DIR" . "$HOME/downloads")
                     ("XDG_MUSIC_DIR" . "$HOME/music")
                     ("XDG_PICTURES_DIR" . "$HOME/pics")
                     ("XDG_VIDEOS_DIR" . "$HOME/vids")
                     ("XDG_CONFIG_DIRS" . "$HOME/.local/etc/xdg:$XDG_CONFIG_DIRS")
                     ("XDG_DATA_DIRS" . ,(string-join (list "$XDG_DATA_HOME"
                                                            "/var/lib/flatpak/exports/share"
                                                            "/home/dandy/.local/share/flatpak/exports/share"
                                                            "$XDG_DATA_DIRS")
                                                      ":"))
                     ("PATH" . ,(string-join (list "$HOME/.local/bin"
                                                   "$HOME/.local/libexec"
                                                   "$XDG_DATA_HOME/flatpak/exports/bin"
                                                   "$HOME/.guix-home/profile/libexec"
                                                   "$HOME/.guix-profile/libexec"
                                                   "/run/current-system/profile/libexec"
                                                   "$PATH")
                                             ":"))

                     ("SSH_AUTH_SOCK" . "$XDG_RUNTIME_DIR/ssh-agent.sock")

                     ("EMACSLOADPATH" . ,(string-join (list "$GUIX_PROFILE/share/emacs/site-lisp" "$EMACSLOADPATH") ":"))

                     ("GUILE_LOAD_PATH" . ,(string-join (list "$HOME/.guix-home/profile/share/guile/site/3.0"
                                                              "$GUIX_PROFILE/share/guile/site/3.0"
                                                              "$GUILE_LOAD_PATH")
                                                        ":"))

                     ("GUILE_LOAD_COMPILED_PATH" . ,(string-join (list "$HOME/.guix-home/profile/lib/guile/3.0/site-ccache"
                                                                       "$HOME/.guix-profile/lib/guile/3.0/site-ccache"
                                                                       "$HOME/.guix-home/profile/share/guile/site/3.0"
                                                                       "$HOME/.guix-profile/share/guile/site/3.0"
                                                                       "$GUILE_LOAD_COMPILED_PATH")
                                                                 ":"))

                     ("QT_PLUGIN_PATH" . ,(string-join (list "$HOME/.guix-home/profile/lib/qt5/plugins"
                                                             "$HOME/.guix-profile/profile/lib/qt5/plugins"
                                                             "$QT_PLUGIN_PATH")
                                                       ":"))

                     ("DICPATH" . "$XDG_DATA_HOME/hunspell:$DICPATH")
                     ("MANPATH" . "$XDG_DATA_HOME/man:$MANPATH")
                     ("INFOPATH" . "$XDG_DATA_HOME/info:$INFOPATH")

                     ("CPLUS_INCLUDE_PATH" . ,(string-join (list "$HOME/.local/include/c++"
                                                                 "$HOME/.local/include"
                                                                 "$HOME/.guix-home/profile/include"
                                                                 "$HOME/.guix-profile/include"
                                                                 "/run/current-system/profile/include"
                                                                 "$CPLUS_INCLUDE_PATH")
                                                           ":"))

                     ("C_INCLUDE_PATH" . ,(string-join (list "$HOME/.local/include"
                                                             "$HOME/.guix-home/profile/include"
                                                             "$HOME/.guix-profile/include"
                                                             "/run/current-system/profile/include"
                                                             "$C_INCLUDE_PATH")
                                                       ":"))

                     ("LIBRARY_PATH" . ,(string-join (list "$HOME/.local/lib"
                                                           "$HOME/.local/lib64"
                                                           "$HOME/.guix-home/profile/lib"
                                                           "$HOME/.guix-profile/lib"
                                                           "$LIBRARY_PATH"
                                                           "/run/current-system/profile/lib")
                                                     ":"))

                     ("LD_LIBRARY_PATH" . ,(string-join (list "$HOME/.local/lib"
                                                              "$HOME/.local/lib64"
                                                              "$LIBRARY_PATH"
                                                              "$LD_LIBRARY_PATH")
                                                        ":"))))

   (simple-service 'additional-fonts-service
                   home-fontconfig-service-type
                   (list "$XDG_DATA_HOME/share/fonts"))


   (service home-zsh-service-type
            (home-zsh-configuration
             (xdg-flavor? #t)
             ;; (environment-variables
             ;;  `(("PATH" . "$PATH:$HOME/.guix-home/profile/libexec:/bin")))
             ))

   (service home-dbus-service-type)
   (service home-shepherd-service-type
            (home-shepherd-configuration
             (auto-start? #t)
             (services
              (list
               (shepherd-service
                (provision '(emacs emacsd))
                (documentation "Emacs, the free, self-documenting editor")
                (start #~(make-forkexec-constructor
                          (list #$(file-append emacs-next-pgtk "/bin/emacs")
                          "--fg-daemon")))
                (stop #~(make-kill-destructor))
                (respawn? #t))

               (shepherd-service
                (provision '(mpd))
                (respawn? #t)
                (documentation "The music player daemon")
                (start #~(make-system-constructor "mpd"))
                (stop #~(make-system-destructor "mpd --kill")))

               (shepherd-service
                (provision '(ssh-agent))
                (respawn? #t)
                (documentation "Run the ssh-agent")
                (start #~(make-forkexec-constructor (list #$(file-append openssh "/bin/ssh-agent") "-D" "-a" (string-append (getenv "XDG_RUNTIME_DIR") "/ssh-agent.sock"))))
                (stop #~(make-kill-destructor)))
               ))))
   )))
