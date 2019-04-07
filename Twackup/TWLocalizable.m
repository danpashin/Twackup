//
//  TWLocalizable.m
//  twackup
//
//  Created by Даниил on 05/01/2019.
//  Copyright © 2019 Даниил. All rights reserved.
//

#import "TWLocalizable.h"
bool locale_is_russian(void);

const char *localized(char *string)
{    
    if (!locale_is_russian()) {
        return string;
    }
    
    if (strcmp(string, "Done") == 0) {
        return "Готово";
    } 
    else if (strcmp(string, "Processing") == 0) {
        return "Обработка";
    }
    else if (strcmp(string, "Archiving...") == 0) {
        return "Архивируем...";
    }
    else if (strcmp(string, "Package %s not found") == 0) {
        return "Пакет %s не найден!";
    }
    else if (strcmp(string, "Preparing packages. Please, wait...\n") == 0) {
        return "Подготовка пакетов. Пожалуйста, подождите...\n";
    }
    else if (strcmp(string, "Found") == 0) {
        return "Найдено";
    }
    else if (strcmp(string, "packages") == 0) {
        return "пакетов";
    }
    else if (strcmp(string, "\nBackup successfully finished! Go to '%s' for viewing. deb packages.\n") == 0) {
        return "\nКопирование успешно завершено! Перейдите в '%s' для просмотра .deb пакетов.\n";
    }
    else if (strcmp(string, "\nBackup was successful, however, the following packages could not be built:\n%s\n") == 0) {
        return "\nКопирование прошло успешно, но следующие пакеты собрать не удалось:\n%s\n";
    }
    else if (strcmp(string, "\nBackup completed successfully! Go to '%s' to view the archive.\n") == 0) {
        return "\nКопирование успешно завершено! Перейдите в '%s' для просмотра архива.\n";
    }
    else if (strcmp(string, "\nPackages were successfully built, but archiving failed. Go to '%s' to view deb files.\n") == 0) {
        return "\nПакеты успешно собраны, но архивирование не удалось. Перейдите в '%s' для просмотра deb-файлов.\n";
    }
    else if (strcmp(string, "\nCopying was successful, but the following packages could not be built:\n%s\n") == 0) {
        return "\nКопирование прошло успешно, но следующие пакеты собрать не удалось:\n%s\n";
    }
    else if (strcmp(string, "Packaging %s failed.") == 0) {
        return "Сборка %s не удалась.";
    }
    
    return string;
}

const char *localized_help_message(void)
{
    if (locale_is_russian()) {
        return 
        "Использование:" "\n"
        "twackup [-a] [-z] [-b package]" "\n" "\n"
        "  -a|--all Собирает все установленные твики в deb-файлы." "\n"
        "  -z  Упаковывает все обработанные deb-файлы в один zip-архив." "\n"
        "   Эти два параметра можно использовать совместно." "\n"
        "\n"
        "  -b|--build [идентификаторы пакетов] Собирает пакеты с указанными идентификаторами в deb-файлы." "\n"
        "\n"
        "  -l|--list-installed Выводит на экран имена и идентификаторы всех установленных пакетов." "\n"
        "\n"
        "  -v|--version Показывает версию утилиты." "\n"
        "  --debug Shows debug info while copying files" "\n";
    }
    
    
    return 
    "Usage:" "\n"
    "twackup [-a] [-z] [-b package]" "\n" "\n"
    "  -a|--all Packages all installed tweaks back to deb's." "\n"
    "  -z  Archives all processed deb files into a single zip." "\n"
    "  These two parameters can be used together." "\n"
    "\n"
    "  -b|--build [packages identifiers] Gathers packets with the specified IDs in a .deb files." "\n"
    "\n"
    "  -l|--list-installed Prints names and identifiers of all installed packages." "\n"
    "\n"
    "  -v|--version Shows the version of the utility." "\n"
    "  --debug Shows debug info while copying files" "\n";
}

bool locale_is_russian(void)
{
    NSString *lang = [NSLocale preferredLanguages].firstObject.lowercaseString;
    return [lang containsString:@"ru"];
}
