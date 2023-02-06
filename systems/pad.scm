
(use-modules (gnu)
             (gnu packages)
             (gnu services)
             (nongnu packages linux)
             (nongnu system linux-initrd)
             (guix gexp))

(use-package-modules gnome scanner cups freedesktop shells bash emacs nano video gl gnupg)
(use-service-modules admin base cups dbus desktop networking ssh)


(define btrfs-mount-defaults "space_cache=v2,ssd,compress=zstd:3")

(operating-system
 (host-name "pad")
 (kernel linux)
 (initrd microcode-initrd)
 (firmware (list linux-firmware))

 (timezone "Europe/Berlin")
 (locale "en_US.utf8")

 (keyboard-layout (keyboard-layout "de" "altgr-intl" #:model "thinkpad"))

 (bootloader (bootloader-configuration
              (bootloader grub-efi-bootloader)
              (targets '("/boot/efi"))
              (keyboard-layout keyboard-layout)))

 (users (cons (user-account
               (name "dandy")
               (comment "primary user and admin")
               (group "users")
               (shell (file-append zsh "/bin/zsh"))
               (supplementary-groups '("wheel"
                                       "audio" "video" "disk" "input")))
              %base-user-accounts))

 (mapped-devices
  (list (mapped-device
         (source (uuid "11584664-b6b6-4c0d-9e61-934eb33b51a7"))
         (target "cryptroot")
         (type luks-device-mapping))))

 (file-systems (cons* (file-system
                       (device (uuid "a21c0001-b630-4729-add0-be429eab1fcd"))
                       (mount-point "/")
                       (type "btrfs")
                       (needed-for-boot? #t)
                       (options (string-append "subvol=/no-snap/@root,subvolid=1056," btrfs-mount-defaults))
                       (dependencies mapped-devices))
                      (file-system
                       (device (uuid "a21c0001-b630-4729-add0-be429eab1fcd"))
                       (mount-point "/home")
                       (type "btrfs")
                       (needed-for-boot? #t)
                       (options (string-append "subvol=/@home,subvolid=1063," btrfs-mount-defaults))
                       (dependencies mapped-devices))
                      (file-system
                       (device (uuid "a21c0001-b630-4729-add0-be429eab1fcd"))
                       (mount-point "/swap")
                       (type "btrfs")
                       (needed-for-boot? #t)
                       (options "subvol=/no-snap/@swap,subvolid=1054,defaults")
                       (dependencies mapped-devices))
                      (file-system
                       (device (uuid "a21c0001-b630-4729-add0-be429eab1fcd"))
                       (mount-point "/gnu/store")
                       (type "btrfs")
                       (needed-for-boot? #t)
                       (options (string-append "subvol=/no-snap/@store,subvolid=1055," btrfs-mount-defaults))
                       (dependencies mapped-devices))
                      (file-system
                       (device (uuid "C482-7228" 'fat))
                       (mount-point "/boot/efi")
                       (type "vfat"))
                      %base-file-systems))

 (swap-devices
  (list
   (swap-space
    (target "/swap/swapfile")
    (dependencies (filter (file-system-mount-point-predicate "/")
                          file-systems)))))

 (packages
  (append (map specification->package
	       '("btrfs-progs" "cryptsetup" "curl" "dnsmasq" "emacs-next-pgtk" "git" "gnupg" "htop" "kitty" "make" "mesa" "nano" "neovim" "network-manager" "network-manager-openvpn" "nss-certs" "ntfs-3g" "ntp" "libva" "libva-utils" "openntpd" "openssh" "pipewire" "radeontop" "rsync" "stow" "tree" "vdpauinfo" "wget" "wireguard-tools" "wireplumber" "xdg-desktop-portal-gtk" "xf86-video-amdgpu" "zsh" "strace" "lsof" "pinentry" "qtwayland@5"))
	  %base-packages))

 (services
  (append (list (service network-manager-service-type
		         (network-manager-configuration
		          (dns "dnsmasq")
		          (vpn-plugins (list network-manager-openvpn))))
	        (service ntp-service-type
		         (ntp-configuration
		          (allow-large-adjustment? #t)))
	        (service wpa-supplicant-service-type)
	        (service bluetooth-service-type
		         (bluetooth-configuration
		          (pairable-timeout 120)
		          (fast-connectable? #t)))
		(elogind-service
                 #:config (elogind-configuration
                           (handle-power-key 'suspend)
                           (handle-lid-switch 'suspend)))
                (service sane-service-type sane-backends)
	        (polkit-service)
	        polkit-wheel-service
	        (udisks-service)
	        (dbus-service)
	        (service cups-service-type
		         (cups-configuration
		          (web-interface? #t)
		          (extensions
		           (list cups-filters hplip splix))))
		(extra-special-file "/usr/bin/env" (file-append coreutils "/bin/env"))
		(extra-special-file "/bin/sh" (file-append bash "/bin/sh"))
		(extra-special-file "/bin/bash" (file-append bash "/bin/bash"))
		(extra-special-file "/bin/zsh" (file-append zsh "/bin/zsh"))
        (extra-special-file "/bin/xdg-desktop-portal-gtk" (file-append xdg-desktop-portal-gtk "/libexec/xdg-desktop-portal-gtk"))
		(extra-special-file "/bin/emacs" (file-append emacs-next-pgtk "/bin/emacs"))
		(extra-special-file "/bin/emacsclient" (file-append emacs-next-pgtk "/bin/emacsclient"))
		(extra-special-file "/bin/nano" (file-append nano "/bin/nano"))
        (extra-special-file "/bin/pinentry" (file-append pinentry "/bin/pinentry-gtk-2"))
        (extra-special-file "/bin/pinentry-curses" (file-append pinentry "/bin/pinentry-curses"))
        (extra-special-file "/bin/pinentry-gtk-2" (file-append pinentry "/bin/pinentry-gtk-2"))

		;; graphics acceleration
		(extra-special-file "/usr/lib/vdpau/libvdpau_radeonsi.so" (file-append mesa "/lib/vdpau/libvdpau_radeonsi.so"))
		(simple-service 'vdpau-driver-service session-environment-service-type
				        '(("VDPAU_DRIVER" . "radeonsi")))
		)
	  (modify-services
	   %base-services
	   (guix-service-type config =>
			      (guix-configuration
			       (inherit config)
			       (substitute-urls (list "https://ci.guix.gnu.org" "https://bordeaux.guix.gnu.org" "https://substitutes.nonguix.org"))
			       (authorized-keys (cons* (plain-file "non-guix.pub" "(public-key
                                                        (ecc (curve Ed25519)
                                                             (q #C1FD53E5D4CE971933EC50C9F307AE2171A2D3B52C804642A7A35F84F3A4EA98#)))")
						       %default-authorized-guix-keys)))))))


)
