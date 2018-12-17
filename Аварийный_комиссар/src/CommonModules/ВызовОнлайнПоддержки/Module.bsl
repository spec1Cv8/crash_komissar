///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2018, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Выполняет действия, необходимые для подключения подсистемы в форме.
//
// Параметры:
//  Элемент - КнопкаФормы - команда вызова онлайн поддержки на форме.
//
Процедура ПриСозданииНаСервере(Элемент) Экспорт
	
	НастройкиПользователя = ВызовОнлайнПоддержкиВызовСервера.НастройкиУчетнойЗаписиПользователя();
	Элемент.Видимость = НастройкиПользователя.ВидимостьКнопкиВызовОнлайнПоддержки;
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

////////////////////////////////////////////////////////////////////////////////
// Обработчики событий подсистем конфигурации.

// См. ОбновлениеИнформационнойБазыБСП.ПриДобавленииОбработчиковОбновления.
Процедура ПриДобавленииОбработчиковОбновления(Обработчики) Экспорт
	
	Обработчик = Обработчики.Добавить();
	Обработчик.НачальноеЗаполнение = Истина;
	Обработчик.Процедура = "ВызовОнлайнПоддержки.ПервоначальноеЗаполнение";		
	
КонецПроцедуры

// См. ОбщегоНазначенияПереопределяемый.ПриДобавленииПереименованийОбъектовМетаданных.
Процедура ПриДобавленииПереименованийОбъектовМетаданных(Итог) Экспорт
	
	Библиотека = "СтандартныеПодсистемы";
	
	СтароеИмя = "Роль.Интеграция1СБухфон";
	НовоеИмя  = "Роль.ВызовОнлайнПоддержки";
	ОбщегоНазначения.ДобавитьПереименование(Итог, "2.4.1.1", СтароеИмя, НовоеИмя, Библиотека);
	
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

// Записывает в регистр сведений путь исполняемого файла онлайн-поддержки. 
// Хранение путей до исполняемых файлов ведется в разрезе ПК, для определения ПК используется идентификатор клиента
// т.к. невозможно использование функции ИмяКомпьютера в веб клиенте.
//
// Параметры:
//		ИдентификаторКлиента	- УникальныйИдентификатор - Идентификатор клиента (программы) 1С.
//		НовоеРасположениеФайла 	- Строка - Расположение исполняемого файла для ПК на котором запущен клиент 1С.
Процедура СохранитьРасположениеИсполняемогоФайлаВызовОнлайнПоддержки(ИдентификаторКлиента, НовоеРасположениеФайла) Экспорт 
	
	ТекущееРасположениеФайла = ВызовОнлайнПоддержкиВызовСервера.РасположениеИсполняемогоФайла(ИдентификаторКлиента);

	Если ТекущееРасположениеФайла = НовоеРасположениеФайла Тогда
		Возврат;	
	КонецЕсли;

	ХранилищеОбщихНастроек.Сохранить("ПутиИсполняемыхФайловВызовОнлайнПоддержки", ИдентификаторКлиента, НовоеРасположениеФайла);
	
КонецПроцедуры

// Записывает в регистр сведений настройки учетных записей пользователей для запуска приложения.
//
// Параметры:
// 		Пользователь            - УникальныйИдентификатор - Текущий пользователь информационной базы.
// 		Логин					- Строка - Данные учетной записи приложения.
// 		Пароль		    		- Строка - Данные учетной записи приложения.
//		ИспользоватьЛП  		- Булево - Если значение Ложь, параметры Логин, Пароль не доступны.
//		ВидимостьКнопкиВызовОнлайнПоддержки - Булево - Отображение Кнопки запуска приложения на начальной странице.
//
Процедура СохранитьНастройкиПользователяВХранилище(Логин, 
										 Пароль, 
										 ИспользоватьЛП, 
										 ВидимостьКнопкиВызовОнлайнПоддержки) Экспорт
		
	НастройкиПользователя = НастройкиПользователя();
	НастройкиПользователя.Логин 					= Логин;
	НастройкиПользователя.Пароль 					= Пароль;
	НастройкиПользователя.ИспользоватьЛП 			= ИспользоватьЛП;
	НастройкиПользователя.ВидимостьКнопкиВызовОнлайнПоддержки 	= ВидимостьКнопкиВызовОнлайнПоддержки;		
	
	ХранилищеОбщихНастроек.Сохранить("УчетныеЗаписиПользователейВызовОнлайнПоддержки", "НастройкиУчетныхДанных", НастройкиПользователя);
	
КонецПроцедуры

Функция НастройкиПользователя() Экспорт
	
	НастройкиПользователя = Новый Структура();
	НастройкиПользователя.Вставить("Логин", "");
	НастройкиПользователя.Вставить("Пароль","");
	НастройкиПользователя.Вставить("ИспользоватьЛП",Ложь);
	НастройкиПользователя.Вставить("ВидимостьКнопкиВызовОнлайнПоддержки",Ложь);	
	
	Возврат НастройкиПользователя;
	
КонецФункции

Процедура ПервоначальноеЗаполнение() Экспорт
	Константы.ИспользоватьОнлайнПоддержку.Установить(Истина);
КонецПроцедуры
	
#КонецОбласти



