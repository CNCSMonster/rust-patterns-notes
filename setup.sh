#!/bin/bash
# Rust Patterns Notes - Setup Script
# 本脚本帮助安装 mdBook 并构建笔记

set -e

echo "🦀 Rust Patterns Notes - 安装脚本"
echo "=================================="

# 检查 cargo 是否安装
if ! command -v cargo &> /dev/null; then
    echo "❌ 错误：未找到 cargo。请先安装 Rust。"
    echo "   访问：https://rustup.rs/"
    exit 1
fi

echo "✅ Rust 已安装：$(rustc --version)"

# 安装 mdBook
echo ""
echo "📦 安装 mdBook..."

if command -v cargo-binstall &> /dev/null; then
    echo "使用 cargo-binstall 安装（更快）..."
    cargo binstall --no-confirm mdbook
else
    echo "使用 cargo install 安装（可能需要几分钟）..."
    cargo install mdbook
fi

echo ""
echo "✅ mdBook 已安装：$(mdbook --version)"

# 构建笔记
echo ""
echo "📖 构建笔记..."
cd "$(dirname "$0")"
mdbook build

echo ""
echo "✅ 构建完成！"
echo ""
echo "📂 输出目录：./book/"
echo ""
echo "🌐 在浏览器中打开："
echo "   firefox book/index.html"
echo "   或 chromium book/index.html"
echo ""
echo "🔧 开发服务器（自动重载）："
echo "   mdbook serve --open"
echo ""
