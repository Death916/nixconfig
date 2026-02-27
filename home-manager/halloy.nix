{
  config,
  pkgs,
  unstablePkgs,
  ...
}:

{
  programs.halloy = {
    enable = true;
    package = pkgs.halloy;
    settings = {
      notifications = {
        direct_message = {
          sound = "peck";
          show_toast = true;
        };
        connected = {
          sound = "peck";
          show_toast = true;
        };
        highlight = {
          sound = "dong";
          show_toast = true;
          show_content = true;
          exclude = [ "NickServ" ];
        };
      };

      servers.libera = {
        nickname = "death916";
        username = "death916/libera";
        server = "100.72.187.12";
        port = 6667;
        chathistory = true;
        use_tls = false;
        dangerously_accept_invalid_certs = true;
        logging = true;
        buffer = "replace-pane";
        password_file = "/home/death916/.config/halloy/libera.pass";
        sasl.plain = {
          username = "death916";
          password_file = "/home/death916/.config/halloy/libera.pass";
        };
      };

      servers.oftc = {
        nickname = "death916";
        username = "death916/oftc";
        server = "100.72.187.12";
        port = 6697;
        use_tls = false;
      };

      actions = {
        buffer.click_channel_name = "replace-pane";
        sidebar = {
          click_channel_name = "replace-pane";
          buffer = "replace-pane";
        };
      };

      font.size = 16;

      buffer = {
        server_messages = {
          join = {
            smart = 30;
            enabled = false;
          };
          part = {
            smart = 30;
          };
          quit = {
            smart = 30;
          };
          topic = {
            enabled = false;
          };
          change_nick = {
            smart = 10;
          };
          change_host = {
            smart = 45;
          };
        };
        url = {
          prompt_before_open = true;
        };
        channel.nicklist.width = 100;
        scroll_position_on_open = "newest";
        chathistory.infinite_scroll = true;
      };

      sidebar = {
        click_channel_name = "replace-pane";
        default_action = "replace-pane";
        buffer = "replace-pane";
      };

      logging.enabled = true;
    };
  };
}
