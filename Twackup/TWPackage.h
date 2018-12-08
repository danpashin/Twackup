//
//  TWPackage.h
//  Twackup
//
//  Created by Даниил on 07/12/2018.
//  Copyright © 2018 Даниил. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface TWPackage : NSObject

/**
 Идентификатор пакета.
 */
@property (copy, nonatomic, readonly) NSString *identifier;

/**
 Версия пакета.
 */
@property (copy, nonatomic, readonly) NSString *version;

/**
 Архитектура пакета.
 */
@property (copy, nonatomic, readonly) NSString *architecture;


- (instancetype)initWithID:(NSString *)identifier version:(NSString *)version architecture:(NSString *)architecture;

/**
 Собирает .deb из файлов пакета.
 */
- (void)buildDebAtURL:(NSURL *)tempURL;

@end



@interface TWPackage (dpkgSupport)

/**
 Получает все пакеты, что есть в системе. Сортировку, фильтрование не выполняет.
 
 @return Возвращает массив пакетов.
 */
+ (NSArray <TWPackage *> *)getAllPackages;


+ (NSArray <NSString *> *)filesForPackage:(NSString *)package;

+ (NSMutableString * _Nullable)controlForPackage:(NSString *)package;


+ (NSRegularExpression * _Nullable)regexForControlLineNamed:(NSString *)lineName;

@end

NS_ASSUME_NONNULL_END
