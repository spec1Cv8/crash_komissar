///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2018, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область СлужебныйПрограммныйИнтерфейс

// Представление компоненты для журнала регистрации
//
Функция ПредставлениеКомпоненты(Идентификатор, Версия) Экспорт
	
	Если ЗначениеЗаполнено(Версия) Тогда 
		ПредставлениеКомпоненты = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = '%1 (версии %2)'"), 
			Идентификатор, 
			Версия);
	Иначе 
		ПредставлениеКомпоненты = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
			НСтр("ru = '%1 (последней версии)'"), 
			Идентификатор, 
			Версия);
	КонецЕсли;
	
	Возврат ПредставлениеКомпоненты;
	
КонецФункции

// Проверят доступна ли загрузка внешних компонент с портала.
//
// Возвращаемое значение:
//  Булево - признак доступности.
//
Функция ДоступнаЗагрузкаСПортала() Экспорт 
	
	Если ОбщегоНазначения.ПодсистемаСуществует("ИнтернетПоддержкаПользователей.ПолучениеВнешнихКомпонент") Тогда 
		МодульПолучениеВнешнихКомпонент = ОбщегоНазначения.ОбщийМодуль("ПолучениеВнешнихКомпонент");
		Возврат МодульПолучениеВнешнихКомпонент.ДоступнаЗагрузкаВнешнихКомпонент();
	КонецЕсли;
	
	Возврат Ложь;
	
КонецФункции

// Разбирает файл компоненты для получения служебной информации о компоненте
//
// Параметры:
//  АдресХранилищаФайла - Строка - адрес хранилища, в котором расположены двоичные данные файла компоненты.
//  ВыполнятьРазборИнфоФайла - Булево - (необязательный) требуется ли дополнительно анализировать
//          данные файла INFO.XML, если он есть.
//  ПараметрыПоискаДополнительнойИнформации - Соответствие - (необязательный)
//          См. ВнешниеКомпонентыКлиент.ПараметрыЗагрузки.
//
// Возвращаемое значение:
//  Структура - состав информации.
//      * Разобрано - Булево - признак успешного разбора компоненты.
//      * Реквизиты - Структура - разобранные реквизиты компоненты.
//          ** Windows_x86 - Булево
//          ** Windows_x86_64 - Булево
//          ** Linux_x86 - Булево
//          ** Linux_x86_64 - Булево
//          ** Windows_x86_Firefox - Булево
//          ** Linux_x86_Firefox - Булево
//          ** Linux_x86_64_Firefox - Булево
//          ** Windows_x86_MSIE - Булево
//          ** Windows_x86_64_MSIE - Булево
//          ** Windows_x86_Chrome - Булево
//          ** Linux_x86_Chrome - Булево
//          ** Linux_x86_64_Chrome - Булево
//          ** MacOS_x86_64_Safari - Булево
//          ** Идентификатор - Строка
//          ** Наименование - Строка
//          ** Версия - Строка
//          ** ДатаВерсии - Дата
//          ** ИмяФайла - Строка
//      * ДвоичныеДанные - ДвоичныеДанные - выгрузка файла компоненты.
//      * ДополнительнаяИнформация - Соответствие - информация, полученная по переданным параметрам поиска.
//      * ОписаниеОшибки - Строка - текст ошибки, в случае, если не разобрано.
//
Функция ИнформацияОКомпонентеИзФайла(АдресХранилищаФайла, ВыполнятьРазборИнфоФайла = Истина, 
	Знач ПараметрыПоискаДополнительнойИнформации = Неопределено) Экспорт
	
	Если ПараметрыПоискаДополнительнойИнформации = Неопределено Тогда 
		ПараметрыПоискаДополнительнойИнформации = Новый Соответствие;
	КонецЕсли;
	
	// Значения заполнения по умолчанию.
	Реквизиты = РеквизитыКомпоненты();
	
	// Дополнительная запрашиваемая информация.
	ДополнительнаяИнформация = Новый Соответствие;
	
	// Получение и загрузка двоичных данных компоненты.
	ДвоичныеДанные = ПолучитьИзВременногоХранилища(АдресХранилищаФайла);
	
	// Очищаем выделенную память в хранилище
	УдалитьИзВременногоХранилища(АдресХранилищаФайла);
	
	// Контроль соответствия компоненты.
	НайденМанифест = Ложь;
	
	// Разбор данных архива компоненты.
	Попытка
		Поток = ДвоичныеДанные.ОткрытьПотокДляЧтения();
		ЧтениеАрхива = Новый ЧтениеZipФайла(Поток);
	Исключение
		ТекстОшибки = НСтр("ru = 'В файле отсутствует информация о компоненте.'");
		
		Результат = РезультатРазбораКомпоненты();
		Результат.ОписаниеОшибки = ТекстОшибки;
		
		Возврат Результат;
	КонецПопытки;
	
	ВременныйКаталог = ФайловаяСистема.СоздатьВременныйКаталог("ExtComp");
	
	Для Каждого ЭлементАрхива Из ЧтениеАрхива.Элементы Цикл
		
		Если ЭлементАрхива.Зашифрован Тогда
			
			// Очищаем временные файлы и освобождаем память.
			ФайловаяСистема.УдалитьВременныйКаталог(ВременныйКаталог);
			ЧтениеАрхива.Закрыть();
			Поток.Закрыть();
			
			ТекстОшибки = НСтр("ru = 'ZIP-архив не должен быть зашифрован.'");
			
			Результат = РезультатРазбораКомпоненты();
			Результат.ОписаниеОшибки = ТекстОшибки;
			
			Возврат Результат;
			
		КонецЕсли;
		
		Попытка
			
			// Поиск и разбор манифеста.
			Если НРег(ЭлементАрхива.ИсходноеПолноеИмя) = "manifest.xml" Тогда
				
				Реквизиты.ДатаВерсии = ЭлементАрхива.ВремяИзменения;
				
				ЧтениеАрхива.Извлечь(ЭлементАрхива, ВременныйКаталог);
				ВременныйФайлXML = ВременныйКаталог + ПолучитьРазделительПути() + ЭлементАрхива.ПолноеИмя;
				РазобратьМанифестКомпоненты(ВременныйФайлXML, Реквизиты);
				
				НайденМанифест = Истина;
				
			КонецЕсли;
			
			Если НРег(ЭлементАрхива.ИсходноеПолноеИмя) = "info.xml" И ВыполнятьРазборИнфоФайла Тогда
				
				ЧтениеАрхива.Извлечь(ЭлементАрхива, ВременныйКаталог);
				ВременныйФайлXML = ВременныйКаталог + ПолучитьРазделительПути() + ЭлементАрхива.ПолноеИмя;
				РазобратьИнфоКомпоненты(ВременныйФайлXML, Реквизиты);
				
			КонецЕсли;
			
			Для Каждого ПараметрПоиска Из ПараметрыПоискаДополнительнойИнформации Цикл 
				
				ИмяФайлаXML = ПараметрПоиска.Значение.ИмяФайлаXML;
				
				Если ЭлементАрхива.ИсходноеПолноеИмя = ИмяФайлаXML Тогда 
					
					КлючДополнительнойИнформации = ПараметрПоиска.Ключ;
					ВыражениеXPath = ПараметрПоиска.Значение.ВыражениеXPath;
					
					ЧтениеАрхива.Извлечь(ЭлементАрхива, ВременныйКаталог);
					ВременныйФайлXML = ВременныйКаталог + ПолучитьРазделительПути() + ЭлементАрхива.ПолноеИмя;
					
					ДокументDOM = ДокументDOM(ВременныйФайлXML);
					ЗначениеXPath = ВычислитьВыражениеXPath(ВыражениеXPath, ДокументDOM);
					
					ДополнительнаяИнформация.Вставить(КлючДополнительнойИнформации, ЗначениеXPath);
					
				КонецЕсли;
				
			КонецЦикла;
			
		Исключение
			Результат = РезультатРазбораКомпоненты();
			Результат.ОписаниеОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Ошибка при разборе файла %1
				           |%2'"),
				ЭлементАрхива.ИсходноеПолноеИмя,
				КраткоеПредставлениеОшибки(ИнформацияОбОшибке()));
				
			Возврат Результат;
		КонецПопытки;
	КонецЦикла;
	
	// Очищаем временные файлы и освобождаем память.
	ФайловаяСистема.УдалитьВременныйКаталог(ВременныйКаталог);
	ЧтениеАрхива.Закрыть();
	Поток.Закрыть();
	
	// Контроль соответствия компоненты.
	Если Не НайденМанифест Тогда 
		ТекстОшибки = НСтр("ru = 'В архиве компоненты отсутствует обязательный файл MANIFEST.XML.'");
		
		Результат = РезультатРазбораКомпоненты();
		Результат.ОписаниеОшибки = ТекстОшибки;
		
		Возврат Результат;
	КонецЕсли;
	
	Результат = РезультатРазбораКомпоненты();
	Результат.Разобрано = Истина;
	Результат.Реквизиты = Реквизиты;
	Результат.ДвоичныеДанные = ДвоичныеДанные;
	Результат.ДополнительнаяИнформация = ДополнительнаяИнформация;
	
	Возврат Результат;
	
КонецФункции

#Область ОбработчикиСобытийПодсистемКонфигурации

// См. ГрупповоеИзменениеОбъектовПереопределяемый.ПриОпределенииОбъектовСРедактируемымиРеквизитами.
Процедура ПриОпределенииОбъектовСРедактируемымиРеквизитами(Объекты) Экспорт
	
	Объекты.Вставить(Метаданные.Справочники.ВнешниеКомпоненты.ПолноеИмя(), "РеквизитыРедактируемыеВГрупповойОбработке");
	
КонецПроцедуры

// См. ВыгрузкаЗагрузкаДанныхПереопределяемый.ПриЗаполненииТиповИсключаемыхИзВыгрузкиЗагрузки.
Процедура ПриЗаполненииТиповИсключаемыхИзВыгрузкиЗагрузки(Типы) Экспорт
	
	Типы.Добавить(Метаданные.Справочники.ВнешниеКомпоненты);
	
КонецПроцедуры

// См. СтандартныеПодсистемыСервер.ПриОтправкеДанныхГлавному.
Процедура ПриОтправкеДанныхГлавному(ЭлементДанных, ОтправкаЭлемента, Получатель) Экспорт
	
	Если ТипЗнч(ЭлементДанных) = Тип("СправочникОбъект.ВнешниеКомпоненты") Тогда
		ОтправкаЭлемента = ОтправкаЭлементаДанных.Игнорировать;
	КонецЕсли;
	
КонецПроцедуры

// См. СтандартныеПодсистемыСервер.ПриОтправкеДанныхПодчиненному.
Процедура ПриОтправкеДанныхПодчиненному(ЭлементДанных, ОтправкаЭлемента, СозданиеНачальногоОбраза, Получатель) Экспорт
	
	Если ТипЗнч(ЭлементДанных) = Тип("СправочникОбъект.ВнешниеКомпоненты") Тогда
		ОтправкаЭлемента = ОтправкаЭлементаДанных.Игнорировать;
	КонецЕсли;
	
КонецПроцедуры

// См. СтандартныеПодсистемыСервер.ПриПолученииДанныхОтГлавного.
Процедура ПриПолученииДанныхОтГлавного(ЭлементДанных, ПолучениеЭлемента, ОтправкаНазад, Отправитель) Экспорт
	
	Если ТипЗнч(ЭлементДанных) = Тип("СправочникОбъект.ВнешниеКомпоненты") Тогда
		ПолучениеЭлемента = ПолучениеЭлементаДанных.Игнорировать;
	КонецЕсли;
	
КонецПроцедуры

// См. СтандартныеПодсистемыСервер.ПриПолученииДанныхОтПодчиненного.
Процедура ПриПолученииДанныхОтПодчиненного(ЭлементДанных, ПолучениеЭлемента, ОтправкаНазад, Отправитель) Экспорт
	
	Если ТипЗнч(ЭлементДанных) = Тип("СправочникОбъект.ВнешниеКомпоненты") Тогда
		ПолучениеЭлемента = ПолучениеЭлементаДанных.Игнорировать;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

#Область ИнформацияОСохраненнойКомпоненте

Функция ДоступнаЗагрузкаИзФайла()
	
	Возврат Пользователи.ЭтоПолноправныйПользователь(,, Ложь);
	
КонецФункции

// Параметры:
//  Параметры - Структура - параметры подготовки.
//      * Идентификатор - Строка               - идентификатор объекта внешнего компонента.
//      * Версия        - Строка, Неопределено - версия компоненты.
//
// Возвращаемое значение:
//  Структура - РезультатИнформацииОСохраненнойКомпоненте()
//
Функция ИнформацияОСохраненнойКомпоненте(Идентификатор, Версия = Неопределено) Экспорт
	
	Результат = РезультатИнформацииОСохраненнойКомпоненте();
	
	// Шаг поиска компоненты.
	
	СсылкаИзХранилища = Справочники.ВнешниеКомпоненты.НайтиПоИдентификатору(Идентификатор, Версия);
	
	Если ОбщегоНазначения.РазделениеВключено() 
		И ОбщегоНазначения.ПодсистемаСуществует("СтандартныеПодсистемы.РаботаВМоделиСервиса.ВнешниеКомпонентыВМоделиСервиса") Тогда
		
		МодульСправочникиОбщиеВнешниеКомпоненты = ОбщегоНазначения.ОбщийМодуль("Справочники.ОбщиеВнешниеКомпоненты");
		СсылкаИзОбщегоХранилища = МодульСправочникиОбщиеВнешниеКомпоненты.НайтиПоИдентификатору(Идентификатор, Версия);
		
		Если СсылкаИзХранилища.Пустая() Тогда
			Если СсылкаИзОбщегоХранилища.Пустая() Тогда
				Результат.Состояние = "НеНайдена";
			Иначе 
				Результат.Состояние = "НайденаВОбщемХранилище";
				Результат.Ссылка = СсылкаИзОбщегоХранилища;
			КонецЕсли;
		Иначе 
			Если СсылкаИзОбщегоХранилища.Пустая() Тогда
				Результат.Состояние = "НайденаВХранилище";
				Результат.Ссылка = СсылкаИзХранилища;
			Иначе 
				Если ЗначениеЗаполнено(Версия) Тогда
					// Особый случай: компонента есть и в общем хранилище и в хранилище области,
					// При этом одной и той же версии. Приоритет компоненте области.
					Результат.Состояние = "НайденаВХранилище";
					Результат.Ссылка = СсылкаИзХранилища;
				Иначе 
					ВерсияХранилища = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(СсылкаИзХранилища, "ДатаВерсии");
					ВерсияОбщегоХранилища = ОбщегоНазначения.ЗначениеРеквизитаОбъекта(СсылкаИзОбщегоХранилища, "ДатаВерсии");
					
					Если ВерсияОбщегоХранилища > ВерсияХранилища Тогда 
						Результат.Состояние = "НайденаВОбщемХранилище";
						Результат.Ссылка = СсылкаИзОбщегоХранилища;
					Иначе 
						// Особый случай: компонента есть и в общем хранилище и в хранилище области,
						// При этом если они оказались одной и той же версии. Приоритет компоненте области.
						Результат.Состояние = "НайденаВХранилище";
						Результат.Ссылка = СсылкаИзХранилища;
					КонецЕсли;
				КонецЕсли;
			КонецЕсли;
		КонецЕсли;
		
	Иначе 
		
		Если СсылкаИзХранилища.Пустая() Тогда
			Результат.Состояние = "НеНайдена";
		Иначе
			Результат.Состояние = "НайденаВХранилище";
			Результат.Ссылка = СсылкаИзХранилища;
		КонецЕсли
		
	КонецЕсли;
	
	// Шаг анализа используемой компоненты
	
	Если Результат.Состояние = "НеНайдена" Тогда 
		Возврат Результат;
	КонецЕсли;
	
	Реквизиты = РеквизитыКомпоненты();
	Если Результат.Состояние = "НайденаВХранилище" Тогда 
		Реквизиты.Вставить("Использование"); 
		// Требуется для определения статуса ОтключенаАдминистратором.
		// Есть только у компонент областей.
	КонецЕсли;
	Если Результат.Состояние = "НайденаВОбщемХранилище" Тогда 
		Реквизиты.Удалить("ИмяФайла");
		// У общих компонент нет признака.
	КонецЕсли;
	
	РеквизитыОбъекта = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(Результат.Ссылка, Реквизиты);
	
	ЗаполнитьЗначенияСвойств(Результат.Реквизиты, РеквизитыОбъекта);
	Результат.Местоположение = ПолучитьНавигационнуюСсылку(Результат.Ссылка, "ХранилищеКомпоненты");
	
	Если Результат.Состояние = "НайденаВХранилище" Тогда 
		Если РеквизитыОбъекта.Использование <> Перечисления.ВариантыИспользованияВнешнихКомпонент.Используется Тогда 
			Результат.Состояние = "ОтключенаАдминистратором";
		КонецЕсли;
	КонецЕсли;
	
	Возврат Результат
	
КонецФункции

Функция РезультатИнформацииОСохраненнойКомпоненте()
	
	Результат = Новый Структура;
	Результат.Вставить("Ссылка");
	Результат.Вставить("Реквизиты", РеквизитыКомпоненты());
	Результат.Вставить("Местоположение");
	Результат.Вставить("Состояние");
	// Варианты:
	// * НеНайдена
	// * НайденаВХранилище
	// * НайденаВОбщемХранилище
	// * ОтключенаАдминистратором
	
	Результат.Вставить("ДоступнаЗагрузкаИзФайла", ДоступнаЗагрузкаИзФайла());
	Результат.Вставить("ДоступнаЗагрузкаСПортала", ДоступнаЗагрузкаСПортала());
	
	Возврат Результат;
	
КонецФункции

Функция РеквизитыКомпоненты()
	
	Реквизиты = Новый Структура;
	Реквизиты.Вставить("Windows_x86");
	Реквизиты.Вставить("Windows_x86_64");
	Реквизиты.Вставить("Linux_x86");
	Реквизиты.Вставить("Linux_x86_64");
	Реквизиты.Вставить("Windows_x86_Firefox");
	Реквизиты.Вставить("Linux_x86_Firefox");
	Реквизиты.Вставить("Linux_x86_64_Firefox");
	Реквизиты.Вставить("Windows_x86_MSIE");
	Реквизиты.Вставить("Windows_x86_64_MSIE");
	Реквизиты.Вставить("Windows_x86_Chrome");
	Реквизиты.Вставить("Linux_x86_Chrome");
	Реквизиты.Вставить("Linux_x86_64_Chrome");
	Реквизиты.Вставить("MacOS_x86_64_Safari");
	Реквизиты.Вставить("Идентификатор");
	Реквизиты.Вставить("Наименование");
	Реквизиты.Вставить("Версия");
	Реквизиты.Вставить("ДатаВерсии");
	Реквизиты.Вставить("ИмяФайла");
	
	Возврат Реквизиты;
	
КонецФункции

#КонецОбласти

#Область РазборКомпонентыИзФайла

Функция РезультатРазбораКомпоненты()
	
	Результат = Новый Структура;
	Результат.Вставить("Разобрано", Ложь);
	Результат.Вставить("Реквизиты", Новый Структура);
	Результат.Вставить("ДвоичныеДанные", Неопределено);
	Результат.Вставить("ДополнительнаяИнформация", Новый Соответствие);
	Результат.Вставить("ОписаниеОшибки", "");
	
	Возврат Результат;
	
КонецФункции

Процедура РазобратьМанифестКомпоненты(ФайлXML, Реквизиты)
	
	ЧтениеXML = Новый ЧтениеXML;
	ЧтениеXML.ОткрытьФайл(ФайлXML);
	
	ЧтениеXML.ПерейтиКСодержимому();
	Если ЧтениеXML.Имя = "bundle" И ЧтениеXML.ТипУзла = ТипУзлаXML.НачалоЭлемента Тогда
		Пока ЧтениеXML.Прочитать() Цикл 
			Если ЧтениеXML.Имя = "component" И ЧтениеXML.ТипУзла = ТипУзлаXML.НачалоЭлемента Тогда
				
				ОперационнаяСистема  = НРег(ЧтениеXML.ЗначениеАтрибута("os"));
				ТипКомпоненты        = НРег(ЧтениеXML.ЗначениеАтрибута("type"));
				АрхитектураПлатформы = НРег(ЧтениеXML.ЗначениеАтрибута("arch"));
				ПрограммаПросмотра   = НРег(ЧтениеXML.ЗначениеАтрибута("client"));
				
				Если ОперационнаяСистема = "windows" И АрхитектураПлатформы = "i386"
					И (ТипКомпоненты = "native" Или ТипКомпоненты = "com") Тогда 
					
					Реквизиты.Windows_x86 = Истина;
					Продолжить;
				КонецЕсли;
				
				Если ОперационнаяСистема = "windows" И АрхитектураПлатформы = "x86_64"
					И (ТипКомпоненты = "native" Или ТипКомпоненты = "com") Тогда 
					
					Реквизиты.Windows_x86_64 = Истина;
					Продолжить;
				КонецЕсли;
				
				Если ОперационнаяСистема = "linux" И АрхитектураПлатформы = "i386"
					И ТипКомпоненты = "native" Тогда 
					
					Реквизиты.Linux_x86 = Истина;
					Продолжить;
				КонецЕсли;
				
				Если ОперационнаяСистема = "linux" И АрхитектураПлатформы = "x86_64"
					И ТипКомпоненты = "native" Тогда 
					
					Реквизиты.Linux_x86_64 = Истина;
					Продолжить;
				КонецЕсли;
				
				Если ОперационнаяСистема = "windows" И АрхитектураПлатформы = "i386"
					И ТипКомпоненты = "plugin" И ПрограммаПросмотра = "firefox" Тогда
					
					Реквизиты.Windows_x86_Firefox = Истина;
					Продолжить;
				КонецЕсли;
				
				Если ОперационнаяСистема = "linux" И АрхитектураПлатформы = "i386" 
					И ТипКомпоненты = "plugin" И ПрограммаПросмотра = "firefox" Тогда
					
					Реквизиты.Linux_x86_Firefox = Истина;
					Продолжить;
				КонецЕсли;
				
				Если ОперационнаяСистема = "linux" И АрхитектураПлатформы = "x86_64"
					И ТипКомпоненты = "plugin" И ПрограммаПросмотра = "firefox" Тогда
					
					Реквизиты.Linux_x86_64_Firefox = Истина;
					Продолжить;
				КонецЕсли;
				
				Если ОперационнаяСистема = "windows" И АрхитектураПлатформы = "i386"
					И ТипКомпоненты = "plugin" И ПрограммаПросмотра = "msie" Тогда
					
					Реквизиты.Windows_x86_MSIE = Истина;
					Продолжить;
				КонецЕсли;
				
				Если ОперационнаяСистема = "windows" И АрхитектураПлатформы = "x86_64"
					И ТипКомпоненты = "plugin" И ПрограммаПросмотра = "msie" Тогда
					
					Реквизиты.Windows_x86_64_MSIE = Истина;
					Продолжить;
				КонецЕсли;
				
				Если ОперационнаяСистема = "windows" И АрхитектураПлатформы = "i386"
					И ТипКомпоненты = "plugin" И ПрограммаПросмотра = "chrome" Тогда
					
					Реквизиты.Windows_x86_Chrome = Истина;
					Продолжить;
				КонецЕсли;
				
				Если ОперационнаяСистема = "linux" И АрхитектураПлатформы = "i386"
					И ТипКомпоненты = "plugin" И ПрограммаПросмотра = "chrome" Тогда
					
					Реквизиты.Linux_x86_Chrome = Истина;
					Продолжить;
				КонецЕсли;
				
				Если ОперационнаяСистема = "linux" И АрхитектураПлатформы = "x86_64"
					И ТипКомпоненты = "plugin" И ПрограммаПросмотра = "chrome" Тогда
					
					Реквизиты.Linux_x86_64_Chrome = Истина;
					Продолжить;
				КонецЕсли;
				
				Если ОперационнаяСистема = "macos" 
					И (АрхитектураПлатформы = "x86_64" Или АрхитектураПлатформы = "universal")
					И ТипКомпоненты = "plugin" И ПрограммаПросмотра = "safari" Тогда 
					
					Реквизиты.MacOS_x86_64_Safari = Истина;
					Продолжить;
				КонецЕсли;
				
			КонецЕсли;
		КонецЦикла;  
	КонецЕсли;
	ЧтениеXML.Закрыть();
	
КонецПроцедуры

Процедура РазобратьИнфоКомпоненты(ФайлXML, Реквизиты)
	
	ИнфоРазобран = Ложь;
	
	// Пытаемся разобрать по формату БПО.
	ЧтениеXML = Новый ЧтениеXML;
	ЧтениеXML.ОткрытьФайл(ФайлXML);
	
	ЧтениеXML.ПерейтиКСодержимому();
	Если ЧтениеXML.Имя = "drivers" И ЧтениеXML.ТипУзла = ТипУзлаXML.НачалоЭлемента Тогда
		Пока ЧтениеXML.Прочитать() Цикл
			Если ЧтениеXML.Имя = "component" И ЧтениеXML.ТипУзла = ТипУзлаXML.НачалоЭлемента Тогда
				
				Идентификатор = ЧтениеXML.ЗначениеАтрибута("progid");
				
				Реквизиты.Идентификатор = Сред(Идентификатор, СтрНайти(Идентификатор, ".") + 1);
				Реквизиты.Наименование  = ЧтениеXML.ЗначениеАтрибута("name");
				Реквизиты.Версия        = ЧтениеXML.ЗначениеАтрибута("version");
				
				ИнфоРазобран = Истина;
				
			КонецЕсли;
		КонецЦикла;
	КонецЕсли;
	ЧтениеXML.Закрыть();
	
	Если Не ИнфоРазобран Тогда
		
		// Пытаемся разобрать по формату БЭД.
		ЧтениеXML = Новый ЧтениеXML;
		ЧтениеXML.ОткрытьФайл(ФайлXML);
	
		info = ФабрикаXDTO.ПрочитатьXML(ЧтениеXML);
		Реквизиты.Идентификатор = info.progid;
		Реквизиты.Наименование = info.name;
		Реквизиты.Версия = info.version;
		
		ЧтениеXML.Закрыть();
	
	КонецЕсли;
	
КонецПроцедуры

Функция ВычислитьВыражениеXPath(Выражение, ДокументDOM)
	
	ЗначениеXPath = Неопределено;
	
	Разыменователь = ДокументDOM.СоздатьРазыменовательПИ();
	РезультатXPath = ДокументDOM.ВычислитьВыражениеXPath(Выражение, ДокументDOM, Разыменователь);
	
	УзелРезультата = РезультатXPath.ПолучитьСледующий();
	Если ТипЗнч(УзелРезультата) = Тип("АтрибутDOM") Тогда 
		ЗначениеXPath = УзелРезультата.Значение;
	КонецЕсли;
	
	Возврат ЗначениеXPath
	
КонецФункции

Функция ДокументDOM(ПутьКФайлу)
	
	ЧтениеXML = Новый ЧтениеXML;
	ЧтениеXML.ОткрытьФайл(ПутьКФайлу);
	ПостроительDOM = Новый ПостроительDOM;
	ДокументDOM = ПостроительDOM.Прочитать(ЧтениеXML);
	ЧтениеXML.Закрыть();
	
	Возврат ДокументDOM;
	
КонецФункции

#КонецОбласти

#Область ЗагрузкаСПортала

Процедура ПроверитьДоступностьЗагрузкиСПортала()
	
	Если Не ДоступнаЗагрузкаСПортала() Тогда
		ВызватьИсключение 
			НСтр("ru = 'Обновление внешних компонент не доступно.
			           |Требуется подсистема обновления внешних компонент библиотеки интернет поддержки.'");
	КонецЕсли;
	
КонецПроцедуры

Процедура НоваяКомпонентаСПортала(ПараметрыПроцедуры, АдресРезультата) Экспорт
	
	Если ОбщегоНазначения.ПодсистемаСуществует("ИнтернетПоддержкаПользователей.ПолучениеВнешнихКомпонент") Тогда
		
		Идентификатор = ПараметрыПроцедуры.Идентификатор;
		Версия = ПараметрыПроцедуры.Версия;
		
		ПроверитьДоступностьЗагрузкиСПортала();
		
		МодульПолучениеВнешнихКомпонент = ОбщегоНазначения.ОбщийМодуль("ПолучениеВнешнихКомпонент");
		
		ОписаниеВнешнихКомпонент  = МодульПолучениеВнешнихКомпонент.ОписаниеВнешнихКомпонент();
		ОписаниеВнешнейКомпоненты = ОписаниеВнешнихКомпонент.Добавить();
		ОписаниеВнешнейКомпоненты.Идентификатор = Идентификатор;
		ОписаниеВнешнейКомпоненты.Версия        = Версия;
		
		Если Не ЗначениеЗаполнено(Версия) Тогда
			РезультатОперации = МодульПолучениеВнешнихКомпонент.АктуальныеВерсииВнешнихКомпонент(ОписаниеВнешнихКомпонент);
		Иначе
			РезультатОперации = МодульПолучениеВнешнихКомпонент.ВерсииВнешнихКомпонент(ОписаниеВнешнихКомпонент);
		КонецЕсли;
		
		Если ЗначениеЗаполнено(РезультатОперации.КодОшибки) Тогда
			ТекстИсключения = ?(Пользователи.ЭтоПолноправныйПользователь(),
				РезультатОперации.ИнформацияОбОшибке,
				РезультатОперации.СообщениеОбОшибке);
			ВызватьИсключение ТекстИсключения;
		КонецЕсли;
		
		Если РезультатОперации.ДанныеВнешнихКомпонент.Количество() = 0 Тогда
			ТекстИсключения = НСтр("ru = 'На Портале 1С:ИТС внешняя компонента не обнаружена.'");
			ЗаписьЖурналаРегистрации(НСтр("ru = 'Обновление внешних компонент'",
					ОбщегоНазначения.КодОсновногоЯзыка()),
				УровеньЖурналаРегистрации.Ошибка,,, ТекстИсключения);
			ВызватьИсключение ТекстИсключения;
		КонецЕсли;
		
		СтрокаРезультата = РезультатОперации.ДанныеВнешнихКомпонент[0]; // Фокусировка на первой строке результата.
		
		КодОшибки = СтрокаРезультата.КодОшибки;
		
		Если ЗначениеЗаполнено(КодОшибки) Тогда
			
			ИнформацияОбОшибке = "";
			Если КодОшибки = "ОтсутствуетКомпонента" Тогда 
				ИнформацияОбОшибке = НСтр("ru = 'В сервисе внешних компонент не обнаружена внешняя компонента'");
			ИначеЕсли КодОшибки = "ОтсутствуетВерсия" Тогда
				ИнформацияОбОшибке = НСтр("ru = 'В сервисе внешних компонент не обнаружена требуемая версия внешней компоненты'");
			ИначеЕсли КодОшибки = "ФайлНеЗагружен" Тогда 
				ИнформацияОбОшибке = НСтр("ru = 'При попытке загрузить файл внешней компоненты из сервиса, возникла ошибка'");
			ИначеЕсли КодОшибки = "АктуальнаяВерсия" Тогда
				ИнформацияОбОшибке = 
					НСтр("ru = 'Скорее всего произошла ошибка сервера при загрузке компоненты.
					           |Получен код ошибки: АктуальнаяВерсия, однако в ИБ компоненты не обнаружено.'");
			КонецЕсли;
			
			ТекстОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'При загрузке внешней компоненты %1 возникала ошибка:
				           |%2'"),
				ПредставлениеКомпоненты(Идентификатор, Версия),
				ИнформацияОбОшибке);
			
			ЗаписьЖурналаРегистрации(НСтр("ru = 'Обновление внешних компонент'",
				ОбщегоНазначения.КодОсновногоЯзыка()),
				УровеньЖурналаРегистрации.Ошибка,,,
				ТекстОшибки);
			
			ВызватьИсключение ТекстОшибки;
		КонецЕсли;
		
		Информация = ИнформацияОКомпонентеИзФайла(СтрокаРезультата.АдресФайла, Ложь);
		
		Если Не Информация.Разобрано Тогда 
			ЗаписьЖурналаРегистрации(НСтр("ru = 'Обновление внешних компонент'",
				ОбщегоНазначения.КодОсновногоЯзыка()),
			УровеньЖурналаРегистрации.Ошибка, , , Информация.ОписаниеОшибки);
			ВызватьИсключение Информация.ОписаниеОшибки;
		КонецЕсли;
		
		УстановитьПривилегированныйРежим(Истина);
		
		НачатьТранзакцию();
		Попытка
			// Создание экземпляра компоненты.
			Объект = Справочники.ВнешниеКомпоненты.СоздатьЭлемент();
			Объект.Заполнить(Неопределено); // Конструктор по умолчанию.
			
			ЗаполнитьЗначенияСвойств(Объект, Информация.Реквизиты); // По данным манифеста.
			ЗаполнитьЗначенияСвойств(Объект, СтрокаРезультата);     // По данным с сайта.
			
			Объект.ОписаниеОшибки = СтроковыеФункцииКлиентСервер.ПодставитьПараметрыВСтроку(
				НСтр("ru = 'Загружена с Портала 1С:ИТС. %1.'"),
				ТекущаяДатаСеанса());
			
			Объект.ДополнительныеСвойства.Вставить("ДвоичныеДанныеКомпоненты", Информация.ДвоичныеДанные);
			
			Если Не ЗначениеЗаполнено(Версия) Тогда // Если запрос конкретной версии - пропускаем.
				Объект.ОбновлятьСПортала1СИТС = Объект.ЭтоКомпонентаПоследнейВерсии();
			КонецЕсли;
			
			Объект.Записать();
			ЗафиксироватьТранзакцию();
		Исключение
			ОтменитьТранзакцию();
			ЗаписьЖурналаРегистрации(НСтр("ru = 'Обновление внешних компонент'",
				ОбщегоНазначения.КодОсновногоЯзыка()),
				УровеньЖурналаРегистрации.Ошибка,,, 
				ПодробноеПредставлениеОшибки(ИнформацияОбОшибке()));
			ВызватьИсключение;
		КонецПопытки;
		
	Иначе
		ВызватьИсключение 
			НСтр("ru = 'Ожидается существование подсистемы ""ИнтернетПоддержкаПользователей.ПолучениеВнешнихКомпонент""'");
	КонецЕсли;
	
КонецПроцедуры

Процедура ОбновитьКомпонентыСПортала(ПараметрыПроцедуры, АдресРезультата) Экспорт
	
	Если ОбщегоНазначения.ПодсистемаСуществует("ИнтернетПоддержкаПользователей.ПолучениеВнешнихКомпонент") Тогда
		
		МассивСсылок = ПараметрыПроцедуры.МассивСсылок;
		
		ПроверитьДоступностьЗагрузкиСПортала();
		
		МодульПолучениеВнешнихКомпонент = ОбщегоНазначения.ОбщийМодуль("ПолучениеВнешнихКомпонент");
		ОписаниеВнешнихКомпонент = МодульПолучениеВнешнихКомпонент.ОписаниеВнешнихКомпонент();
		
		Для Каждого Ссылка Из МассивСсылок Цикл 
			Реквизиты = ОбщегоНазначения.ЗначенияРеквизитовОбъекта(Ссылка, "Идентификатор, Версия");
			ОписаниеКомпоненты = ОписаниеВнешнихКомпонент.Добавить();
			ОписаниеКомпоненты.Идентификатор = Реквизиты.Идентификатор;
			ОписаниеКомпоненты.Версия = Реквизиты.Версия;
		КонецЦикла;
		
		РезультатОперации = МодульПолучениеВнешнихКомпонент.АктуальныеВерсииВнешнихКомпонент(ОписаниеВнешнихКомпонент);
		
		Если ЗначениеЗаполнено(РезультатОперации.КодОшибки) Тогда
			ТекстИсключения = ?(Пользователи.ЭтоПолноправныйПользователь(),
				РезультатОперации.ИнформацияОбОшибке,
				РезультатОперации.СообщениеОбОшибке);
			ВызватьИсключение ТекстИсключения;
		КонецЕсли;
		
		ВнешниеКомпонентыСервер.ОбновитьВнешниеКомпоненты(РезультатОперации.ДанныеВнешнихКомпонент, АдресРезультата);
		
	Иначе
		ВызватьИсключение 
			НСтр("ru = 'Ожидается существование подсистемы ""ИнтернетПоддержкаПользователей.ПолучениеВнешнихКомпонент""'");
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти

#КонецОбласти

