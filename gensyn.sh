channel_logo() {
  echo -e '\033[0;31m'
  echo -e '┌┐ ┌─┐┌─┐┌─┐┌┬┐┬┬ ┬  ┌─┐┬ ┬┌┐ ┬┬  '
  echo -e '├┴┐│ ││ ┬├─┤ │ │└┬┘  └─┐└┬┘├┴┐││  '
  echo -e '└─┘└─┘└─┘┴ ┴ ┴ ┴ ┴   └─┘ ┴ └─┘┴┴─┘'
  echo -e '\e[0m'
  echo -e "\n\nПодпишись на самый 4ekHyTbIu* канал в крипте @bogatiy_sybil [💸]"
}

download_node() {
  echo 'Начинаю установку ноды.'

  cd $HOME

  sudo apt install lsof

  ports=(4040 3000 42763)

  for port in "${ports[@]}"; do
    if [[ $(lsof -i :"$port" | wc -l) -gt 0 ]]; then
      echo "Ошибка: Порт $port занят. Программа не сможет выполниться."
      exit 1
    fi
  done

  echo -e "Все порты свободны! Сейчас начнется установка...\n"

  if [ -d "$HOME/rl-swarm" ]; then
    PID=$(netstat -tulnp | grep :3000 | awk '{print $7}' | cut -d'/' -f1)
    sudo kill $PID
    sudo rm -rf rl-swarm/
  fi

  TARGET_SWAP_GB=32
  CURRENT_SWAP_KB=$(free -k | awk '/Swap:/ {print $2}')
  CURRENT_SWAP_GB=$((CURRENT_SWAP_KB / 1024 / 1024))

  echo "Нынешний размер Swap: ${CURRENT_SWAP_GB}GB"
  if [ "$CURRENT_SWAP_GB" -lt "$TARGET_SWAP_GB" ]; then
    swapoff -a
    sed -i '/swap/d' /etc/fstab
    SWAPFILE=/swapfile
    fallocate -l ${TARGET_SWAP_GB}G $SWAPFILE
    chmod 600 $SWAPFILE
    mkswap $SWAPFILE
    swapon $SWAPFILE
    echo "$SWAPFILE none swap sw 0 0" >> /etc/fstab
    echo "vm.swappiness = 10" >> /etc/sysctl.conf
    sysctl -p
    echo "Swap был поставлен на ${TARGET_SWAP_GB}GB"
  fi

  sudo apt update -y && sudo apt upgrade -y
  sudo apt install -y git curl wget build-essential python3 python3-venv python3-pip screen yarn net-tools

  curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
  echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
  curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
  sudo apt install -y nodejs
  sudo apt update
  curl -sSL https://raw.githubusercontent.com/zunxbt/installation/main/node.sh | bash

  git clone https://github.com/zunxbt/rl-swarm.git
  cd rl-swarm

  python3 -m venv .venv
  source .venv/bin/activate

  pip install --upgrade pip

  echo "На вашем сервере только CPU стоит? (если не знаете, нажимаете Y) (Y/N)"
  read answer

  if [ "$answer" = "Y" ] || [ "$answer" = "y" ]; then
    echo "Настраиваем PyTorch для использования только CPU..."
    export PYTORCH_ENABLE_MPS_FALLBACK=1
    export PYTORCH_MPS_HIGH_WATERMARK_RATIO=0.0
    sed -i 's/torch\.device("mps" if torch\.backends\.mps\.is_available() else "cpu")/torch.device("cpu")/g' hivemind_exp/trainer/hivemind_grpo_trainer.py
    echo "Команды выполнены."
  else
    echo "Пропускаем настройку, оставляем как есть."
  fi

  if screen -list | grep -q "gensynnode"; then
    screen -ls | grep gensynnode | cut -d. -f1 | awk '{print $1}' | xargs kill
  fi

  echo 'Следуйте дальше гайду.'
}

launch_node() {
  cd $HOME

  cd rl-swarm
  source .venv/bin/activate

  if screen -list | grep -q "gensynnode"; then
    screen -ls | grep gensynnode | cut -d. -f1 | awk '{print $1}' | xargs kill
  fi

  screen -S gensynnode -d -m bash -c "trap '' INT; bash run_rl_swarm.sh 2>&1 | tee $HOME/rl-swarm/gensynnode.log"
}

watch_logs() {
  echo "Просмотр логов (Ctrl+C для возврата в меню)..."
  trap 'echo -e "\nВозврат в меню..."; return' SIGINT
  tail -n 100 -f $HOME/rl-swarm/gensynnode.log
}

go_to_screen() {
  echo 'ВЫХОДИТЕ ИЗ ЛОГОВ ЧЕРЕЗ CTRL+A + D'
  sleep 2

  screen -r gensynnode
}

open_local_server() {
  npm install -g localtunnel

  SERVER_IP=$(curl -s https://api.ipify.org || curl -s https://ifconfig.co/ip || dig +short myip.opendns.com @resolver1.opendns.com)

  echo "Ваш IP-адрес сервера: $SERVER_IP. Это правильный IP? (y/n)"
  read -r CONFIRM
  
  if [[ $CONFIRM == "y" ]]; then
      echo "IP подтвержден: $SERVER_IP"
  else
      echo "Введите ваш IP-адрес:"
      read -r SERVER_IP
      echo "Вы ввели IP: $SERVER_IP"
  fi

  ssh -L 3000:localhost:3000 root@${SERVER_IP}
  lt --port 3000
}

userdata() {
  cd $HOME
  cat ~/rl-swarm/modal-login/temp-data/userData.json
}

userapikey() {
  cd $HOME
  cat ~/rl-swarm/modal-login/temp-data/userApiKey.json
}

update_node() {
  cd $HOME
  cd ~/rl-swarm
  git fetch origin
  git reset --hard origin/main
  git pull origin main

  echo 'Нода была обновлена.'
}

stop_node() {
  if screen -list | grep -q "gensynnode"; then
    screen -ls | grep gensynnode | cut -d. -f1 | awk '{print $1}' | xargs kill
  fi

  PID=$(netstat -tulnp | grep :3000 | awk '{print $7}' | cut -d'/' -f1)
  sudo kill $PID

  echo 'Нода была остановлена.'
}

delete_node() {
  cd $HOME

  if screen -list | grep -q "gensynnode"; then
    screen -ls | grep gensynnode | cut -d. -f1 | awk '{print $1}' | xargs kill
  fi

  PID=$(netstat -tulnp | grep :3000 | awk '{print $7}' | cut -d'/' -f1)
  sudo kill $PID
  sudo rm -rf rl-swarm/

  echo 'Нода была удалена.'
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
    echo "3. 📜 Посмотреть логи"
    echo "4. 🖥️ Перейти в screen ноды"
    echo "5. 🌐 Запустить локальный сервер"
    echo "6. 👤 Показать данные пользователя"
    echo "7. 🔑 Показать API ключ пользователя"
    echo "8. ✅ Обновить ноду"
    echo "9. ⛔ Остановить ноду"
    echo "10. 🗑️ Удалить ноду"
    echo "11. 👋 Выйти из скрипта"
    read -p "Выберите пункт меню: " choice

    case $choice in
      1)
        download_node
        ;;
      2)
        launch_node
        ;;
      3)
        watch_logs
        ;;
      4)
        go_to_screen
        ;;
      5)
        open_local_server
        ;;
      6)
        userdata
        ;;
      7)
        userapikey
        ;;
      8)
        update_node
        ;;
      9)
        stop_node
        ;;
      10)
        delete_node
        ;;
      11)
        exit_from_script
        ;;
      *)
        echo "Неверный пункт. Пожалуйста, выберите правильную цифру в меню."
        ;;
    esac
  done
