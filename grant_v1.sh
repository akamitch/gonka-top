#!/bin/bash
# https://claude.ai/chat/d0064159-0bcd-45f6-b2d6-49afa20b4ca1
set -e

# ─── Директория скрипта (где лежит inferenced) ───
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
INFERENCED="./inferenced"

# ─── Парсинг аргументов ───
for arg in "$@"; do
  case "$arg" in
    WALLET_NAME=*)        WALLET_NAME="${arg#WALLET_NAME=}" ;;
    GONKA_WARM_ADDRESS=*) GONKA_WARM_ADDRESS="${arg#GONKA_WARM_ADDRESS=}" ;;
    *) echo "⚠️  Неизвестный аргумент: $arg"; exit 1 ;;
  esac
done

if [[ -z "$WALLET_NAME" || -z "$GONKA_WARM_ADDRESS" ]]; then
  echo "Использование:"
  echo "  ./grant.sh WALLET_NAME=sample1 GONKA_WARM_ADDRESS=gonka1wvv656pt2d8x2khcvytqeessck5uzjnxzsa8f6"
  exit 1
fi

NODE="http://node1.gonka.ai:8000/chain-rpc/"
CHAIN="gonka-mainnet"

# ─── Определяем команды ───
COMMENTS=(
  "Разрешить майнить теплому ключу ноды от имени холодного"
  "Внести залог"
  "Верифицировать для Dem пулл"
  "Добавить домен в Description"
)

CMDS=(
  "${INFERENCED} tx inference grant-ml-ops-permissions ${WALLET_NAME} ${GONKA_WARM_ADDRESS} --from ${WALLET_NAME} --keyring-backend file --gas 2000000 --node ${NODE}"
  "${INFERENCED} tx collateral deposit-collateral 1000000ngonka --from ${WALLET_NAME} --keyring-backend file --node ${NODE} --chain-id ${CHAIN} --yes"
  "${INFERENCED} tx bank send ${WALLET_NAME} gonka15tywu0xmcrq5y02tsqxawqfr4fq2uzggveqxe7 100ngonka --keyring-backend file --node ${NODE} --chain-id ${CHAIN} --yes"
  "${INFERENCED} tx staking edit-validator --chain-id=${CHAIN} --from ${WALLET_NAME} --website https:/gonka.top --keyring-backend file --node ${NODE} --yes"
)

# ─── Вывод всех команд ───
echo ""
echo "═══════════════════════════════════════"
echo "  Команды для кошелька: ${WALLET_NAME}"
echo "═══════════════════════════════════════"

for i in "${!CMDS[@]}"; do
  echo ""
  echo "${COMMENTS[$i]}"
  echo '```'
  echo "${CMDS[$i]}"
  echo '```'
done

echo ""
echo "═══════════════════════════════════════"

# ─── Запрос пароля и выполнение ───
read -s -p "Введите пароль для выполнения (Ctrl+C для выхода): " WALLET_PASS
echo ""
echo ""

for i in "${!CMDS[@]}"; do
  echo "▶ ${COMMENTS[$i]}..."
  echo "$WALLET_PASS" | eval "${CMDS[$i]}"
  echo "✅ Готово"
  echo "────────────────────────────────────"
done

echo ""
echo "🎉 Все 4 команды выполнены для кошелька: ${WALLET_NAME}"
