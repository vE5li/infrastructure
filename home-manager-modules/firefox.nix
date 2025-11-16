{config, ...}: {
  # Create "~/downloads/" directory
  home.file."downloads/.keep".text = "";

  programs.firefox = {
    enable = true;
    profiles.main = {
      id = 0;
      isDefault = true;
      settings = {
        # Never ask to remember passwords
        "signon.rememberSignons" = false;
        # Enable userChrome.css
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        # Set download directory
        "browser.download.dir" = "/home/${config.home.username}/downloads";
        # Download files to the downloads folder
        "browser.download.folderList" = 2;
        # Don't show downloads window when download starts
        #"browser.download.manager.showWhenStarting" = false;
        # Always load tabs instantly
        "browser.sessionstore.restore_on_demand" = false;
        "browser.sessionstore.restore_tabs_lazily" = false;
        # Restore previous tabs on startup
        "browser.startup.page" = 3;
        # Privacy
        "browser.search.update" = false;
        "browser.urlbar.suggest.trending" = false;
        # Make UI components smaller
        "browser.uidensity" = 1;
      };
      # extensions = {
      #   packages = with pkgs.nur.repos.rycee.firefox-addons; [
      #     ublock-origin
      #     tridactyl
      #     containers
      #     keepassxc
      #   ];
      # };
      search = {
        engines = {
          kagi = {
            name = "Kagi";
            urls = [{template = "https://kagi.com/search?q={searchTerms}";}];
            definedAliases = ["@kagi"];
          };

          bing.metaData.hidden = true;
          google.metaData.alias = "@g";
        };
        default = "kagi";
        force = true;
      };
      userChrome = ''
        :root {
            --tab-max-height: 20px !important;
            --tab-min-height: 0 !important;
        }

        /* Bar resizing */
        #nav-bar,
        .toolbar-items,
        .titlebar-buttonbox-container,
        .tab-content,
        .tab-background,
        .tab-label-container {
            box-shadow: none !important;
            height: var(--tab-max-height);
            font-size: 10px !important;
        }

        .tab-background {
            margin: 0 !important;
            border-radius: 0px !important;
        }

        .tab-secondary-label {
            font-size: .5em !important;
            margin: -.6em 0 .5em !important;
        }

        /* Selection highlight */
        #nav-bar toolbaritem,
        #nav-bar toolbarbutton {
            --focus-outline: none;
        }
        #nav-bar toolbaritem:focus-visible,
        #nav-bar toolbarbutton:focus-visible,
        #nav-bar toolbaritem #identity-icon-box:focus-visible,
        #nav-bar toolbaritem #star-button-box:focus-visible,

        .toolbarbutton-icon {
            fill: #ebdbb2 !important;
        }

        /* Remove list all tabs button */
        #alltabs-button {
            display: none !important;
        }

        /* Remove close button*/
        .titlebar-buttonbox-container {
            display:none
        }

        /* Remove the "PLAYING" text below the tab name */
        .tab-icon-sound-label {
            display: none !important;
        }

        #tracking-protection-icon-container {
            display: none !important;
        }

        /* Remove URL bar background */
        #urlbar:not([focused]) > #urlbar-background {
            background-color: transparent !important;
        }

        /* Make toolbar icons smaller */
        .toolbarbutton-icon,
        .urlbar-icon,
        #identity-icon {
            padding: 0px !important;
            width: 12px !important;
            height: 12px !important;
        }

        /* Make the area of these specific buttons bigger to make them easier to press */
        :is(#reload-button, #back-button, #forward-button) > .toolbarbutton-icon {
            padding: 2px !important;
            width: 16px !important;
            height: 16px !important;
        }

        .toolbarbutton-1 {
            width: 24px !important;
        }

        /* Fix positioning of the URL bar icons, without this they are off-center */
        .urlbar-page-action {
            width: 18px !important;
            height: 18px !important;
        }

        /* Center the text in the URL bar
         * Source: /* Source file https://github.com/MrOtherGuy/firefox-csshacks/tree/master/chrome/urlbar_centered_text.css
         */
        #urlbar:not([focused]) #urlbar-input, /* ID for Firefox 70 */
        #urlbar:not([focused]) .urlbar-input {
            text-align: center !important;
        }

        /* Source file https://github.com/MrOtherGuy/firefox-csshacks/tree/master/chrome/combined_favicon_and_tab_close_button.css made available under Mozilla Public License v. 2.0
        See the above repository for updates as well as full license text. */

        /* Show tab close button when cursor is over the tab icon */

        /* inline_tab_audio_icons.css is recommended because otherwise you cannot mute the tab using the mute button */

        .tab-content{
            pointer-events: none
        }
        .tab-icon-image:not([busy]) {
            width: 12px !important;
            height: 12px !important;
            display: block !important;
        }
        :where(.tab-content:hover) .tab-icon-image,
        :where(.tab-content:hover) > .tab-icon-stack{
            visibility: hidden;
        }
        .tab-close-button{
            order: -1;
            display: flex !important;
            position: relative;
            margin-inline: -4px -20px !important;
            padding-inline-start: 7px !important;
            opacity: 0;
            width: unset !important;
            pointer-events: auto;
        }
        .tab-close-button:hover{ opacity: 1 }
        .tabbrowser-tab[pinned] .tab-close-button{ display: none !important; }
      '';
    };
  };
}
