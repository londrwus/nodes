channel_logo() {
  echo -e '\033[0;31m'
  echo -e '┌┐ ┌─┐┌─┐┌─┐┌┬┐┬┬ ┬  ┌─┐┬ ┬┌┐ ┬┬  '
  echo -e '├┴┐│ ││ ┬├─┤ │ │└┬┘  └─┐└┬┘├┴┐││  '
  echo -e '└─┘└─┘└─┘┴ ┴ ┴ ┴ ┴   └─┘ ┴ └─┘┴┴─┘'
  echo -e '\e[0m'
  echo -e "\n\nПодпишись на самый 4ekHyTbIu* канал в крипте @bogatiy_sybil [💸]"
}

download_node() {
  echo 'Начинаю установку ноды...'

  cd $HOME

  sudo apt install lsof

  ports=(4001)

  for port in "${ports[@]}"; do
    if [[ $(lsof -i :"$port" | wc -l) -gt 0 ]]; then
      echo "Ошибка: Порт $port занят. Программа не сможет выполниться."
      exit 1
    fi
  done

  sudo apt-get update -y && sudo apt-get upgrade -y
  sudo apt install -y wget make tar screen nano unzip lz4 gcc git jq

  if screen -list | grep -q "drianode"; then
    screen -ls | grep drianode | cut -d. -f1 | awk '{print $1}' | xargs kill
  fi

  if [ -d "$HOME/.dria" ]; then
    dkn-compute-launcher uninstall
    sudo rm rf .dria/
  fi

  curl -fsSL https://ollama.com/install.sh | sh

  curl -fsSL https://dria.co/launcher | bash

  source ~/.bashrc

  screen -S drianode

  echo 'Теперь запускайте ноду.'
}

launch_node() {
  dkn-compute-launcher start
}

settings_node() {
  dkn-compute-launcher settings
}

node_points() {
  dkn-compute-launcher points
}

models_check() {
  dkn-compute-launcher info
}

delete_node() {
  dkn-compute-launcher uninstall

  if screen -list | grep -q "drianode"; then
    screen -ls | grep drianode | cut -d. -f1 | awk '{print $1}' | xargs kill
  fi
}

exit_from_script() {
  exit 0
}

while true; do
    channel_logo
    sleep 2
    echo -e "\n\nМеню:"
    echo "1. 🤺 Установить ноду"
    echo "2. 🚀 Запустить ноду"
    echo "3. ⚙️ Настройки ноды"
    echo "4. 📊 Проверить очки ноды"
    echo "5. 🔍 Проверить модели установленные"
    echo "6. 🗑️ Удалить ноду"
    echo "7. 👋 Выйти из скрипта"
    read -p "Выберите пункт меню: " choice

    case $choice in
      1)
        download_node
        ;;
      2)
        launch_node
        ;;
      3)
        settings_node
        ;;
      4)
        node_points
        ;;
      5)
        models_check
        ;;
      6)
        delete_node
        ;;
      7)
        exit_from_script
        ;;
      *)
        echo "Неверный пункт. Пожалуйста, выберите правильную цифру в меню."
        ;;
    esac
  done
