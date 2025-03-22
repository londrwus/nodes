channel_logo() {
  echo -e '\033[0;31m'
  echo -e '┌┐ ┌─┐┌─┐┌─┐┌┬┐┬┬ ┬  ┌─┐┬ ┬┌┐ ┬┬  '
  echo -e '├┴┐│ ││ ┬├─┤ │ │└┬┘  └─┐└┬┘├┴┐││  '
  echo -e '└─┘└─┘└─┘┴ ┴ ┴ ┴ ┴   └─┘ ┴ └─┘┴┴─┘'
  echo -e '\e[0m'
  echo -e "\n\nПодпишись на самый 4ekHyTbIu* канал в крипте @bogatiy_sybil [💸]"
}

update_node() {
  delete_node

  if [ -d "$HOME/executor" ] || screen -list | grep -q "\.t3rnnode"; then
    echo 'Папка executor или сессия t3rnnode уже существуют. Установка невозможна. Выберите удалить ноду или выйти из скрипта.'
    return
  fi

  echo 'Начинаю обновление ноды...'

  read -p "Введите ваш приватный ключ: " PRIVATE_KEY_LOCAL

  cd $HOME

  echo "Выберите вариант установки:"
  echo "1) Установить последнюю версию"
  echo "2) Установить конкретную версию"
  read -p "Введите номер варианта (1 или 2): " CHOICE

  if [ "$CHOICE" = "1" ]; then
    sudo curl -s https://api.github.com/repos/t3rn/executor-release/releases/latest | \
      grep -Po '"tag_name": "\K.*?(?=")' | \
      xargs -I {} wget https://github.com/t3rn/executor-release/releases/download/{}/executor-linux-{}.tar.gz
    sudo tar -xzf executor-linux-*.tar.gz
    sudo rm -rf executor-linux-*.tar.gz
  elif [ "$CHOICE" = "2" ]; then
    read -p "Введите номер версии (например, 53 для v0.53.0): " VERSION
    VERSION_FULL="v0.${VERSION}.0"
    sudo wget https://github.com/t3rn/executor-release/releases/download/${VERSION_FULL}/executor-linux-${VERSION_FULL}.tar.gz -O executor-linux.tar.gz
    sudo tar -xzvf executor-linux.tar.gz
    sudo rm -rf executor-linux.tar.gz
  else
    echo "Неверный выбор. Установка отменена."
    return
  fi

  cd executor

  export ENVIRONMENT="testnet"
  export LOG_LEVEL="debug"
  export LOG_PRETTY="false"
  export EXECUTOR_PROCESS_BIDS_ENABLED=true
  export EXECUTOR_PROCESS_ORDERS_ENABLED=true
  export EXECUTOR_PROCESS_CLAIMS_ENABLED=true
  export ENABLED_NETWORKS='arbitrum-sepolia,base-sepolia,optimism-sepolia,l2rn'
  export PRIVATE_KEY_LOCAL="$PRIVATE_KEY_LOCAL"
  export EXECUTOR_PROCESS_BIDS_ENABLED=true
  export EXECUTOR_ENABLE_BATCH_BIDING=true
  export EXECUTOR_PROCESS_PENDING_ORDERS_FROM_API=false
  export EXECUTOR_PROCESS_ORDERS_API_ENABLED=false
  export EXECUTOR_ENABLE_BATCH_BIDDING=true
  export EXECUTOR_PROCESS_BIDS_BATCH=true
  export RPC_ENDPOINTS='{
      "l2rn": ["https://b2n.rpc.caldera.xyz/http"],
      "arbt": ["https://arbitrum-sepolia.drpc.org", "https://sepolia-rollup.arbitrum.io/rpc"],
      "bast": ["https://base-sepolia-rpc.publicnode.com", "https://base-sepolia.drpc.org"],
      "opst": ["https://sepolia.optimism.io", "https://optimism-sepolia.drpc.org"],
      "unit": ["https://unichain-sepolia.drpc.org", "https://sepolia.unichain.org"],
      "bssp": ["https://base-sepolia-rpc.publicnode.com/", "https://sepolia.base.org"],
      "blst": ["https://blast-sepolia-rpc.example.com"]
  }'
  export EXECUTOR_MAX_L3_GAS_PRICE=1050

  cd $HOME/executor/executor/bin/

  screen -dmS t3rnnode bash -c '
    echo "Начало выполнения скрипта в screen-сессии"

    cd $HOME/executor/executor/bin/
    ./executor

    exec bash
  '

  echo "Screen сессия 't3rnnode' создана и нода запущена..."
}

download_node() {
  if [ -d "$HOME/executor" ] || screen -list | grep -q "\.t3rnnode"; then
    echo 'Папка executor или сессия t3rnnode уже существуют. Установка невозможна. Выберите удалить ноду или выйти из скрипта.'
    return
  fi

  echo 'Начинаю установку ноды...'

  read -p "Введите ваш приватный ключ: " PRIVATE_KEY_LOCAL

  sudo apt update -y && sudo apt upgrade -y
  sudo apt-get install make screen build-essential software-properties-common curl git nano jq -y

  echo "Выберите вариант установки:"
  echo "1) Установить последнюю версию"
  echo "2) Установить конкретную версию"
  read -p "Введите номер варианта (1 или 2): " CHOICE

  if [ "$CHOICE" = "1" ]; then
    sudo curl -s https://api.github.com/repos/t3rn/executor-release/releases/latest | \
      grep -Po '"tag_name": "\K.*?(?=")' | \
      xargs -I {} wget https://github.com/t3rn/executor-release/releases/download/{}/executor-linux-{}.tar.gz
    sudo tar -xzf executor-linux-*.tar.gz
    sudo rm -rf executor-linux-*.tar.gz
  elif [ "$CHOICE" = "2" ]; then
    read -p "Введите номер версии (например, 53 для v0.53.0): " VERSION
    VERSION_FULL="v0.${VERSION}.0"
    sudo wget https://github.com/t3rn/executor-release/releases/download/${VERSION_FULL}/executor-linux-${VERSION_FULL}.tar.gz -O executor-linux.tar.gz
    sudo tar -xzvf executor-linux.tar.gz
    sudo rm -rf executor-linux.tar.gz
  else
    echo "Неверный выбор. Установка отменена."
    return
  fi

  cd executor

  export ENVIRONMENT="testnet"
  export LOG_LEVEL="debug"
  export LOG_PRETTY="false"
  export EXECUTOR_PROCESS_BIDS_ENABLED=true
  export EXECUTOR_PROCESS_ORDERS_ENABLED=true
  export EXECUTOR_PROCESS_CLAIMS_ENABLED=true
  export ENABLED_NETWORKS='arbitrum-sepolia,base-sepolia,optimism-sepolia,l2rn'
  export PRIVATE_KEY_LOCAL="$PRIVATE_KEY_LOCAL"
  export EXECUTOR_PROCESS_BIDS_ENABLED=true
  export EXECUTOR_ENABLE_BATCH_BIDING=true
  export EXECUTOR_PROCESS_PENDING_ORDERS_FROM_API=false
  export EXECUTOR_PROCESS_ORDERS_API_ENABLED=false
  export EXECUTOR_ENABLE_BATCH_BIDDING=true
  export EXECUTOR_PROCESS_BIDS_BATCH=true
  export RPC_ENDPOINTS='{
      "l2rn": ["https://b2n.rpc.caldera.xyz/http"],
      "arbt": ["https://arbitrum-sepolia.drpc.org", "https://sepolia-rollup.arbitrum.io/rpc"],
      "bast": ["https://base-sepolia-rpc.publicnode.com", "https://base-sepolia.drpc.org"],
      "opst": ["https://sepolia.optimism.io", "https://optimism-sepolia.drpc.org"],
      "unit": ["https://unichain-sepolia.drpc.org", "https://sepolia.unichain.org"],
      "bssp": ["https://base-sepolia-rpc.publicnode.com/", "https://sepolia.base.org"]
  }'
  export EXECUTOR_MAX_L3_GAS_PRICE=1050

  cd $HOME/executor/executor/bin/

  screen -dmS t3rnnode bash -c '
    echo "Начало выполнения скрипта в screen-сессии"

    cd $HOME/executor/executor/bin/
    ./executor

    exec bash
  '

  echo "Screen сессия 't3rnnode' создана и нода запущена..."
}

check_logs() {
  if screen -list | grep -q "\.t3rnnode"; then
    screen -S t3rnnode -X hardcopy -h /tmp/screen_log.txt
    sleep 0.1
    
    if [ -f /tmp/screen_log.txt ]; then
      echo "=== Последние логи t3rnnode ==="
      echo "----------------------------------------"
      tail -n 40 /tmp/screen_log.txt | awk '{print "\033[0;32m" NR "\033[0m: " $0}'
      echo "----------------------------------------"
      echo "Логи успешно выведены (время: $(date '+%H:%M:%S %d.%m.%Y'))"
      rm -f /tmp/screen_log.txt
    else
      echo "Ошибка: Не удалось получить логи из screen-сессии."
    fi
  else
    echo "Сессия t3rnnode не найдена."
  fi
}

change_fee() {
    echo 'Начинаю изменение комиссии...'

    if [ ! -d "$HOME/executor" ]; then
        echo 'Папка executor не найдена. Установите ноду.'
        return
    fi

    session="t3rnnode"

    read -p 'На какой газ GWEI вы хотите изменить? (по стандарту 1050) ' GWEI_SET

    if screen -list | grep -q "\.${session}"; then
      screen -S "${session}" -p 0 -X stuff "^C"
      sleep 1
      screen -S "${session}" -p 0 -X stuff "export EXECUTOR_MAX_L3_GAS_PRICE=$GWEI_SET\n"
      sleep 1
      screen -S "${session}" -p 0 -X stuff "./executor\n"
      echo 'Комиссия была изменена.'
    else
      echo "Сессия ${session} не найдена. Газ не может поменяться"
      return
    fi
}

stop_node() {
  echo 'Начинаю остановку...'

  if screen -list | grep -q "\.t3rnnode"; then
    screen -S t3rnnode -p 0 -X stuff "^C"
    echo "Нода была остановлена."
  else
    echo "Сессия t3rnnode не найдена."
  fi
}

auto_restart_node() {
  screen_name="t3rnnode_auto"
  script_path="$HOME/t3rn_restart.sh"

  if screen -list | grep -q "\.$screen_name"; then
    screen -X -S "$screen_name" quit
    echo "Существующий screen '$screen_name' был остановлен."
  fi

  cat > "$script_path" << 'EOF'
restart_node() {
  echo 'Начинаю перезагрузку...'

  session="t3rnnode"
  
  if screen -list | grep -q "\.${session}"; then
    screen -S "${session}" -p 0 -X stuff "^C"
    sleep 1
    screen -S "${session}" -p 0 -X stuff "./executor\n"
    echo "Нода была перезагружена."
  else
    echo "Сессия ${session} не найдена."
  fi
}

while true; do
  restart_node
  sleep 7200
done
EOF
  chmod +x "$script_path"

  screen -dmS "$screen_name" bash "$script_path"
  echo "Screen-сессия '$screen_name' создана, нода будет перезапускаться каждые 2 часа."

  (crontab -l 2>/dev/null | grep -v "$script_path"; echo "@reboot screen -dmS $screen_name bash $script_path") | crontab -
  echo "Задание добавлено в crontab для автозапуска при перезагрузке сервера."
}

restart_node() {
  echo 'Начинаю перезагрузку...'

  session="t3rnnode"
  
  if screen -list | grep -q "\.${session}"; then
    screen -S "${session}" -p 0 -X stuff "^C"
    sleep 1
    screen -S "${session}" -p 0 -X stuff "./executor\n"
    echo "Нода была перезагружена."
  else
    echo "Сессия ${session} не найдена."
  fi
}

delete_node() {
  echo 'Начинаю удаление ноды...'

  if [ -d "$HOME/executor" ]; then
    sudo rm -rf $HOME/executor
    echo "Папка executor была удалена."
  else
    echo "Папка executor не найдена."
  fi

  if screen -list | grep -q "\.t3rnnode"; then
    sudo screen -X -S t3rnnode quit
    echo "Сессия t3rnnode была закрыта."
  else
    echo "Сессия t3rnnode не найдена."
  fi

  sudo screen -X -S t3rnnode_auto quit

  echo "Нода была удалена."
}

exit_from_script() {
  exit 0
}

while true; do
    channel_logo
    sleep 2
    echo -e "\n\nМеню:"
    echo "1. 🚀 Установить ноду"
    echo "2. 📋 Проверить логи ноды"
    echo "3. 🐾 Изменить комиссию"
    echo "4. 🛑 Остановить ноду"
    echo "5. 🔄 Перезапустить ноду"
    echo "6. 📈 Автоперезагрузка ноды"
    echo "7. ✅ Обновить ноду"
    echo "8. 🗑️ Удалить ноду"
    echo -e "9. 🚪 Выйти из скрипта\n"
    read -p "Выберите пункт меню: " choice

    case $choice in
      1)
        download_node
        ;;
      2)
        check_logs
        ;;
      3)
        change_fee
        ;;
      4)
        stop_node
        ;;
      5)
        restart_node
        ;;
      6)
        auto_restart_node
        ;;
      7)
        update_node
        ;;
      8)
        delete_node
        ;;
      9)
        exit_from_script
        ;;
      *)
        echo "Неверный пункт. Пожалуйста, выберите правильную цифру в меню."
        ;;
    esac
  done
