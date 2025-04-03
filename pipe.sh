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

  if [ -d "$HOME/pop" ]; then
    sudo rm -rf download_cache
    sudo rm node_info.json
    sudo rm pop
  fi

  sudo apt install lsof

  ports=(8003)

  for port in "${ports[@]}"; do
    if [[ $(lsof -i :"$port" | wc -l) -gt 0 ]]; then
      echo "Ошибка: Порт $port занят. Программа не сможет выполниться."
      exit 1
    fi
  done

  sudo apt update -y && sudo apt upgrade -y
  sudo apt-get install wget make tar screen nano unzip lz4 git jq -y

  while true; do
      read -p "Введите количество выделяемой оперативной памяти (RAM, минимум 4): " RAM
      if [[ "$RAM" =~ ^[0-9]+$ ]] && [ "$RAM" -ge 4 ]; then
          break
      else
          echo "RAM значение должно быть числом и больше или равно 4."
      fi
  done
  
  while true; do
      read -p "Введите количество выделяемого места на диске (минимум 100гб): " DISK_SPACE
      if [[ "$DISK_SPACE" =~ ^[0-9]+$ ]] && [ "$DISK_SPACE" -ge 100 ]; then
          break
      else
          echo "Объем диска должен быть числом и минимум 100гб."
      fi
  done
  
  while true; do
      read -p "Введите ваш SOL адрес (НЕ ПРИВАТНЫЙ КЛЮЧ): " SOLADDRESS
      if [ -n "$SOLADDRESS" ]; then
          break
      else
          echo "Адрес соланы не может быть пустым."
      fi
  done

  wget -O pop "https://dl.pipecdn.app/v0.2.8/pop"
  chmod +x pop

  mkdir download_cache

  sudo ./pop  --ram ${RAM}   --max-disk ${DISK_SPACE}  --cache-dir $HOME/download_cache --pubKey ${SOLADDRESS} --signup-by-referral-route 63d264373ecf57ec

  sudo tee /etc/systemd/system/pipe.service > /dev/null << EOF
[Unit]
Description=Pipe Node Service
After=network.target
Wants=network-online.target

[Service]
User=$(whoami)
Group=$(whoami)
WorkingDirectory=$HOME
ExecStart=$HOME/pop \\
    --ram ${RAM} \\
    --max-disk ${DISK_SPACE} \\
    --cache-dir $HOME/download_cache \\
    --pubKey ${SOLADDRESS} 
Restart=always
RestartSec=5
LimitNOFILE=65536
LimitNPROC=4096
StandardOutput=journal
StandardError=journal
SyslogIdentifier=pipe-node

[Install]
WantedBy=multi-user.target
EOF

  sudo systemctl daemon-reload
  sudo systemctl enable pipe
  sudo systemctl start pipe

  sleep 5

  echo 'Нода была установлена.'
}

check_logs() {
  echo "Показываю последние 40 строк логов Pipe."

  journalctl -u pipe -n 40 --output=short | awk '{print $1, $2, $3, substr($0, index($0,$5))}'
}

check_node_status() {
  local attempts=0
  local max_attempts=10
  local output

  echo "Проверка статуса и репутации ноды."
  
  cd $HOME
  
  while [ $attempts -lt $max_attempts ]; do
    output=$(./pop --status 2>&1)
    
    echo "$output"
    
    last_two_lines=$(echo "$output" | tail -n 2)
    if [[ "$last_two_lines" != *"Parsed node_info.json"* ]]; then
      break
    fi
    
    attempts=$((attempts + 1))
    echo "Попытка $attempts: Обнаружен 'Parsed node_info.json' в последних двух строках, повторяем..."
    sleep 1
  done
  
  if [ $attempts -eq $max_attempts ]; then
    echo "Достигнуто максимальное количество попыток ($max_attempts)"
  fi
}

display_node_info() {
  echo "Отображение содержимого node_info.json."
  if [ -f $HOME/node_info.json ]; then
    cat $HOME/node_info.json
  else
    echo "Файл node_info.json не найден."
  fi
}

restart_node() {
  echo "Перезапуск Pipe Node."

  sudo systemctl daemon-reload
  sudo systemctl enable pipe
  sudo systemctl restart pipe

  echo "Pipe успешно перезапущена."
}

stop_node() {
  echo "Остановка Pipe Node."

  sudo systemctl stop pipe

  echo "Pipe успешно остановлена."
}

delete_node() {
  cd $HOME
}

exit_from_script() {
  exit 0
}

while true; do
    channel_logo
    sleep 2
    echo -e "\n\nМеню:"
    echo "1. 😊 Установить ноду"
    echo "2. 📜 Просмотреть логи"
    echo "3. 🔍 Проверить статус ноды"
    echo "4. 📱 Показать информацию о ноде"
    echo "5. 🔄 Перезапустить ноду"
    echo "6. ⛔ Остановить ноду"
    echo "7. 🗑️ Удалить ноду"
    echo "8. 🚪 Выйти из скрипта"
    read -p "Выберите пункт меню: " choice

    case $choice in
      1)
        download_node
        ;;
      2)
        check_logs
        ;;
      3)
        check_node_status
        ;;
      4)
        display_node_info
        ;;
      5)
        restart_node
        ;;
      6)
        stop_node
        ;;
      7)
        delete_node
        ;;
      8)
        exit_from_script
        ;;
      *)
        echo "Неверный пункт. Пожалуйста, выберите правильную цифру в меню."
        ;;
    esac
  done
