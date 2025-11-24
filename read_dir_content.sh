#!/bin/bash

# Параметры по умолчанию
output_file=""
exclude_dirs=()
target_dir="."

# Функция для вывода справки
usage() {
    echo "Использование: $0 -o <output_file> [--exclude <dir1>] [--exclude <dir2>] [<target_dir>]"
    echo "Пример: $0 -o project.txt --exclude vendor --exclude node_modules ."
    exit 1
}

# Разбор аргументов командной строки
while [[ $# -gt 0 ]]; do
    case $1 in
        -o)
            output_file="$2"
            shift 2
            ;;
        --exclude)
            exclude_dirs+=("$2")
            shift 2
            ;;
        -*)
            echo "Неизвестная опция: $1"
            usage
            ;;
        *)
            target_dir="$1"
            shift
            ;;
    esac
done

# Проверка обязательных параметров
if [[ -z "$output_file" ]]; then
    echo "Ошибка: Требуется указать выходной файл с помощью -o"
    usage
fi

# Проверка существования целевой директории
if [[ ! -d "$target_dir" ]]; then
    echo "Ошибка: Директория '$target_dir' не существует"
    exit 1
fi

# Создание временного файла
temp_file=$(mktemp)

# Построение find команды с исключениями
find_command="find \"$target_dir\" -type f"

if [[ ${#exclude_dirs[@]} -gt 0 ]]; then
    for exclude_dir in "${exclude_dirs[@]}"; do
        find_command+=" -not -path \"*/$exclude_dir/*\""
    done
fi

# Выполнение обхода и обработка файлов
eval "$find_command" | while read -r file; do
    # Получаем относительный путь
    relative_path="${file#$(readlink -f "$target_dir")/}"
    
    # Проверяем, что файл читаем
    if [[ -r "$file" ]]; then
        # Записываем путь к файлу
        echo "// $relative_path" >> "$temp_file"
        # Записываем содержимое файла
        cat "$file" >> "$temp_file"
        # Добавляем разделитель между файлами
        echo "" >> "$temp_file"
    else
        echo "Предупреждение: Невозможно прочитать файл $file" >&2
    fi
done

# Перемещаем временный файл в окончательный
mv "$temp_file" "$output_file"

echo "Структура проекта сохранена в: $output_file"
