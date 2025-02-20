#!/bin/bash

# 오류 발생 시 스크립트 종료
set -e

echo "===== 개발 환경 설정 스크립트 시작 ====="

# 함수: 명령어 실행 상태 확인
check_command() {
  if [ $? -eq 0 ]; then
    echo "✓ $1 성공"
  else
    echo "✗ $1 실패"
    exit 1
  fi
}

# apt 저장소 업데이트
echo "시스템 패키지 정보 업데이트 중..."
sudo apt update
check_command "apt update"

# 기본 빌드 도구 설치
echo "build-essential 설치 중..."
sudo apt install build-essential -y
check_command "build-essential 설치"

# SSL 개발 라이브러리 설치
echo "libssl-dev 및 pkg-config 설치 중..."
sudo apt install libssl-dev pkg-config -y
check_command "libssl-dev 및 pkg-config 설치"

# unzip 설치
echo "unzip 설치 중..."
sudo apt install unzip -y
check_command "unzip 설치"

# Rust 설치 여부 확인
if command -v rustc &> /dev/null; then
  echo "Rust가 이미 설치되어 있습니다. 버전: $(rustc --version)"
else
  echo "Rust 설치 중..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  check_command "Rust 설치"
  
  # 환경변수 설정
  source "$HOME/.cargo/env"
fi

# rustup 설치 여부 확인
if ! command -v rustup &> /dev/null; then
  echo "rustup 설치 중..."
  sudo snap install rustup --classic
  check_command "rustup snap 설치"
fi

# RISC-V 타겟 추가
echo "RISC-V 타겟 추가 중..."
rustup target add riscv32i-unknown-none-elf
check_command "RISC-V 타겟 추가"

# Protocol Buffers 설치
echo "Protocol Buffers 설치 중..."
if command -v protoc &> /dev/null; then
  echo "protoc가 이미 설치되어 있습니다. 버전: $(protoc --version)"
else
  TEMP_DIR=$(mktemp -d)
  cd "$TEMP_DIR"
  curl -LO https://github.com/protocolbuffers/protobuf/releases/download/v25.6/protoc-25.6-linux-x86_64.zip
  sudo unzip protoc-25.6-linux-x86_64.zip -d /usr
  check_command "Protocol Buffers 설치"
  cd - > /dev/null
  rm -rf "$TEMP_DIR"
fi

# Nexus CLI 설치
echo "Nexus CLI 설치 중..."
if command -v nexus &> /dev/null; then
  echo "Nexus CLI가 이미 설치되어 있습니다."
else
  curl https://cli.nexus.xyz/ | sh
  check_command "Nexus CLI 설치"
fi

echo "===== 설치 완료 ====="
echo "설치된 버전:"
echo "Rust: $(rustc --version)"
echo "Cargo: $(cargo --version)"
echo "Rustup: $(rustup --version)"
echo "Protoc: $(protoc --version)"
if command -v nexus &> /dev/null; then
  echo "Nexus CLI가 설치되었습니다."
fi

echo "모든 구성 요소가 성공적으로 설치되었습니다!"
