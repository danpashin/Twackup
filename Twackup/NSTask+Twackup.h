//
//  NSTask+Twackup.h
//  Twackup
//
//  Created by Даниил on 07/12/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import "NSTask.h"

NS_ASSUME_NONNULL_BEGIN

@interface NSTask (Twackup)

/**
 Синхронно выполняет системную команду.

 @param executablePath Полный путь к выполняемому бинарникую
 @param arguments Аргументы для команды.
 @param output Возвращает данные, полученные в процессе выполнения команды.
 @return Возвращает YES в случае успеха.
 */
+ (BOOL)syncronouslyExecute:(NSString *)executablePath
                  arguments:(NSArray <NSString *> * _Nullable)arguments
                     output:(NSData * _Nullable * _Nullable)output;

@end

NS_ASSUME_NONNULL_END
