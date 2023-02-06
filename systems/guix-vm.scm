(use-modules (gnu)
             (gnu packages)
             (gnu system)
             (gnu services)
             (nongnu packages linux)
             (nongnu system linux-initrd)
             (guix gexp)
             (dandy systems vars)
             (dandy systems base))

(use-service-modules ssh)

;; (define btrfs-mount-defaults "rw,relatime,space_cache=v2,ssd,compress=zstd:3")
(define btrfs-mount-defaults "space_cache=v2,ssd,compress=zstd:3")

(operating-system
 (inherit %my-os-base-graphical)

 (kernel linux)
 (initrd microcode-initrd)
 (firmware (list linux-firmware))

 (host-name "guix-vm")

 (bootloader (bootloader-configuration
              (bootloader grub-efi-bootloader)
              (targets '("/boot/efi"))
              (keyboard-layout (keyboard-layout "de" "altgr-intl" #:model "thinkpad"))))

 (services (modify-services
            %my-base-desktop-services
            (openssh-service-type
             config =>
             (openssh-configuration
              (inherit config)
              (authorized-keys
               `(("root" ,(plain-file "peripheral.pub" "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC396Yc98MPKd6LoG2APQ0HM9JCvQLtXgxZoT+YJtVbf87OTz96CAb9rWzrULuq+3/yMSi3uJ8qAys1xCD3TJFA8JYc22BCCtOXyuZegBQXEQUj/RsUOFr3p0i3Pk4dk4CWYKvn2RIUiirimFXfBKEjdAtQPkMqYO9bgeDdtiupJG+GRA2xl92oYtR9oTik1B57Q5y3w+vApUytoVF0qE5WQ6WEdWwYjRdAGp/UbMapqwXHQ7/sdT518n+inKUpm+nQOY9vh+F6GnnvDUWncaZGJy4aLb9rbslwhVLrcYflFmBaN0g9YMA3fmOyV8uwEGtUxGoENNl1SAJxww6A0YGtbRAiuU1aWURov63QTEpBhHgoAuqov1GLzBSLde5krECaOH+VAAjdskMAYtQFLNVsVybesu2ZMVK2vdnqX/2aiseSo0LXDq47fET0ChUSZySsYBhgL/NY/ID5Bu30I6TF47qI/gcHjSl1MoY7gHg6Y5yN6Yh1rSnDrkwAovAmPP9/leuBkZOlss9ks/2FiK5mi+GhkXvatKLXg/cpEDPuNUt8N2NTTWcfVA3M98mbsSdGbC6KKVA3GHcK2OFArgt9meUV39SrxfqiQ+20GWzFA46igRQNQeOGsNZSzAAo9HHT/blKaOcYkrPtvbReaiZlpNd/zsPXpjTmABUsw3ex0w== dandy,daniel.tschertkow@posteo.de,peripheral"))
                 ("dandy" ,(plain-file "peripheral.pub" "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC396Yc98MPKd6LoG2APQ0HM9JCvQLtXgxZoT+YJtVbf87OTz96CAb9rWzrULuq+3/yMSi3uJ8qAys1xCD3TJFA8JYc22BCCtOXyuZegBQXEQUj/RsUOFr3p0i3Pk4dk4CWYKvn2RIUiirimFXfBKEjdAtQPkMqYO9bgeDdtiupJG+GRA2xl92oYtR9oTik1B57Q5y3w+vApUytoVF0qE5WQ6WEdWwYjRdAGp/UbMapqwXHQ7/sdT518n+inKUpm+nQOY9vh+F6GnnvDUWncaZGJy4aLb9rbslwhVLrcYflFmBaN0g9YMA3fmOyV8uwEGtUxGoENNl1SAJxww6A0YGtbRAiuU1aWURov63QTEpBhHgoAuqov1GLzBSLde5krECaOH+VAAjdskMAYtQFLNVsVybesu2ZMVK2vdnqX/2aiseSo0LXDq47fET0ChUSZySsYBhgL/NY/ID5Bu30I6TF47qI/gcHjSl1MoY7gHg6Y5yN6Yh1rSnDrkwAovAmPP9/leuBkZOlss9ks/2FiK5mi+GhkXvatKLXg/cpEDPuNUt8N2NTTWcfVA3M98mbsSdGbC6KKVA3GHcK2OFArgt9meUV39SrxfqiQ+20GWzFA46igRQNQeOGsNZSzAAo9HHT/blKaOcYkrPtvbReaiZlpNd/zsPXpjTmABUsw3ex0w== dandy,daniel.tschertkow@posteo.de,peripheral"))))))))

 (mapped-devices
  (list (mapped-device
         (source (uuid "66d7e589-df6f-4227-8563-0f352b99a3df"))
         (target "cryptroot")
         (type luks-device-mapping))))

 (file-systems (cons* (file-system
                       (device (uuid "580a53ac-b15d-4438-ac66-b04c9dfa49d8"))
                       (mount-point "/")
                       (type "btrfs")
                       (needed-for-boot? #t)
                       (options (string-append "subvol=/no-snap/@root,subvolid=258," btrfs-mount-defaults))
                       (dependencies mapped-devices))
                      (file-system
                       (device (uuid "580a53ac-b15d-4438-ac66-b04c9dfa49d8"))
                       (mount-point "/home")
                       (type "btrfs")
                       (needed-for-boot? #t)
                       (options (string-append "subvol=/@home,subvolid=256," btrfs-mount-defaults))
                       (dependencies mapped-devices))
                      (file-system
                       (device (uuid "580a53ac-b15d-4438-ac66-b04c9dfa49d8"))
                       (mount-point "/swap")
                       (type "btrfs")
                       (needed-for-boot? #t)
                       (options "subvol=/no-snap/@swap,subvolid=257,defaults")
                       (dependencies mapped-devices))
                      (file-system
                       (device (uuid "580a53ac-b15d-4438-ac66-b04c9dfa49d8"))
                       (mount-point "/gnu/store")
                       (type "btrfs")
                       (needed-for-boot? #t)
                       (options (string-append "subvol=/no-snap/@store,subvolid=259," btrfs-mount-defaults))
                       (dependencies mapped-devices))
                      (file-system
                       (device (uuid "86C6-50B9"'fat))
                       (mount-point "/boot/efi")
                       (type "vfat"))
                      %base-file-systems))


 (swap-devices
  (list
   (swap-space
    (target "/swap/swapfile")
    (dependencies (filter (file-system-mount-point-predicate "/")
                          file-systems)))))
 )
