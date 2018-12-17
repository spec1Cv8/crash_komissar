///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2018, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Заполняет значение реквизита дополнительного упорядочивания у объекта.
//
// Параметры:
//  Источник - Объект - записываемый объект;
//  Отказ    - Булево - признак отказа от записи объекта.
Процедура ЗаполнитьЗначениеРеквизитаУпорядочивания(Источник, Отказ) Экспорт
	
	Если Источник.ОбменДанными.Загрузка Тогда 
		Возврат; 
	КонецЕсли;
	
	// Если в обработчике был установлен отказ новый порядок не вычисляем.
	Если Отказ Тогда
		Возврат;
	КонецЕсли;
	
	Если СтандартныеПодсистемыСервер.ЭтоИдентификаторОбъектаМетаданных(Источник) Тогда
		Возврат;
	КонецЕсли;
	
	// Проверим, есть ли у объекта реквизит доп. упорядочивания.
	Информация = ПолучитьИнформациюДляПеремещения(Источник.Ссылка.Метаданные());
	Если Не УОбъектаЕстьРеквизитДопУпорядочивания(Источник, Информация) Тогда
		Возврат;
	КонецЕсли;
	
	// При переносе элемента в другую группу порядок переназначается.
	Если Информация.ЕстьРодитель И ОбщегоНазначения.ЗначениеРеквизитаОбъекта(Источник.Ссылка, "Родитель") <> Источник.Родитель Тогда
		Источник.РеквизитДопУпорядочивания = 0;
	КонецЕсли;
	
	// Вычислим новое значение для порядка элемента.
	Если Источник.РеквизитДопУпорядочивания = 0 Тогда
		Источник.РеквизитДопУпорядочивания =
			НастройкаПорядкаЭлементовСлужебный.ПолучитьНовоеЗначениеРеквизитаДопУпорядочивания(
					Информация,
					?(Информация.ЕстьРодитель, Источник.Родитель, Неопределено),
					?(Информация.ЕстьВладелец, Источник.Владелец, Неопределено));
	КонецЕсли;
	
КонецПроцедуры

// Обнуляет значение реквизита дополнительного упорядочивания у объекта.
//
// Параметры:
//  Источник          - Объект - объект, создаваемый копированием;
//  ОбъектКопирования - Ссылка - исходный объект, который является источником копирования.
Процедура СброситьЗначениеРеквизитаУпорядочивания(Источник, ОбъектКопирования) Экспорт
	
	Если СтандартныеПодсистемыСервер.ЭтоИдентификаторОбъектаМетаданных(Источник) Тогда
		Возврат;
	КонецЕсли;
	
	Информация = ПолучитьИнформациюДляПеремещения(Источник.Ссылка.Метаданные());
	Если УОбъектаЕстьРеквизитДопУпорядочивания(Источник, Информация) Тогда
		Источник.РеквизитДопУпорядочивания = 0;
	КонецЕсли;
	
КонецПроцедуры

// Возвращает структуру с информацией о метаданных объекта.
// 
// Параметры:
//  МетаданныеОбъекта - ОбъектМетаданных - метаданные перемещаемого объекта.
//
// Возвращаемое значение:
//  Структура - информация из метаданных объекта.
Функция ПолучитьИнформациюДляПеремещения(МетаданныеОбъекта) Экспорт
	
	Информация = Новый Структура;
	
	МетаданныеРеквизита = МетаданныеОбъекта.Реквизиты.РеквизитДопУпорядочивания;
	
	Информация.Вставить("ПолноеИмя",    МетаданныеОбъекта.ПолноеИмя());
	
	ЭтоСправочник = Метаданные.Справочники.Содержит(МетаданныеОбъекта);
	ЭтоПВХ        = Метаданные.ПланыВидовХарактеристик.Содержит(МетаданныеОбъекта);
	
	Если ЭтоСправочник ИЛИ ЭтоПВХ Тогда
		
		Информация.Вставить("ЕстьГруппы", МетаданныеОбъекта.Иерархический
			И ?(ЭтоПВХ, Истина, МетаданныеОбъекта.ВидИерархии = Метаданные.СвойстваОбъектов.ВидИерархии.ИерархияГруппИЭлементов));
		
		Информация.Вставить("ДляГрупп",     (МетаданныеРеквизита.Использование <> Метаданные.СвойстваОбъектов.ИспользованиеРеквизита.ДляЭлемента));
		Информация.Вставить("ДляЭлементов", (МетаданныеРеквизита.Использование <> Метаданные.СвойстваОбъектов.ИспользованиеРеквизита.ДляГруппы));
		Информация.Вставить("ЕстьРодитель",  МетаданныеОбъекта.Иерархический);
		Информация.Вставить("ГруппыСверху", ?(НЕ Информация.ЕстьРодитель, Ложь, МетаданныеОбъекта.ГруппыСверху));
		Информация.Вставить("ЕстьВладелец", ?(ЭтоПВХ, Ложь, (МетаданныеОбъекта.Владельцы.Количество() <> 0)));
		
	Иначе
		
		Информация.Вставить("ЕстьГруппы",   Ложь);
		Информация.Вставить("ДляГрупп",     Ложь);
		Информация.Вставить("ДляЭлементов", Истина);
		Информация.Вставить("ЕстьРодитель", Ложь);
		Информация.Вставить("ЕстьВладелец", Ложь);
		Информация.Вставить("ГруппыСверху", Ложь);
		
	КонецЕсли;
	
	Возврат Информация;
	
КонецФункции

#КонецОбласти

#Область СлужебныйПрограммныйИнтерфейс

// Перемещает элемент вверх или вниз в списке.
Процедура Подключаемый_ПереместитьЭлемент(Ссылка, ПараметрыВыполнения) Экспорт
	Направление = ПараметрыВыполнения.ОписаниеКоманды.Идентификатор;
	ТекстОшибки = НастройкаПорядкаЭлементовСлужебный.ПереместитьЭлемент(ПараметрыВыполнения.Источник, Ссылка, Направление);
	ПараметрыВыполнения.Результат.Текст = ТекстОшибки;
КонецПроцедуры

// См. ПодключаемыеКомандыПереопределяемый.ПриОпределенииВидовПодключаемыхКоманд.
Процедура ПриОпределенииВидовПодключаемыхКоманд(ВидыПодключаемыхКоманд) Экспорт
	Вид = ВидыПодключаемыхКоманд.Добавить();
	Вид.Имя         = "НастройкаПорядкаЭлементов";
	Вид.ИмяПодменю  = "НастройкаПорядкаЭлементов";
	Вид.Заголовок   = НСтр("ru = 'Настройка порядка элементов'");
	Вид.ВидГруппыФормы = ВидГруппыФормы.ГруппаКнопок;
КонецПроцедуры

// См. ПодключаемыеКомандыПереопределяемый.ПриОпределенииКомандПодключенныхКОбъекту.
Процедура ПриОпределенииКомандПодключенныхКОбъекту(НастройкиФормы, Источники, ПодключенныеОтчетыИОбработки, Команды) Экспорт
	
	ОбъектыСНастраиваемымПорядком = Новый Массив;
	Для Каждого Тип Из Метаданные.ОпределяемыеТипы.ОбъектСНастраиваемымПорядком.Тип.Типы() Цикл
		ОбъектМетаданных = Метаданные.НайтиПоТипу(Тип);
		ОбъектыСНастраиваемымПорядком.Добавить(ОбъектМетаданных.ПолноеИмя());
	КонецЦикла;
	
	ВыводитьКоманды = Ложь;
	Для Каждого Источник Из Источники.Строки Цикл
		Если ОбъектыСНастраиваемымПорядком.Найти(Источник.ПолноеИмя) <> Неопределено Тогда
			ВыводитьКоманды = ПравоДоступа("Изменение", Источник.Метаданные);
			Прервать;
		КонецЕсли;
	КонецЦикла;
	Если Не ВыводитьКоманды Тогда
		Возврат;
	КонецЕсли;
	
	Команда = Команды.Добавить();
	Команда.Вид = "НастройкаПорядкаЭлементов";
	Команда.Идентификатор = "Вверх";
	Команда.Представление = НСтр("ru = 'Переместить элемент вверх'");
	Команда.Порядок = 1;
	Команда.Картинка = БиблиотекаКартинок.ПереместитьВверх;
	Команда.ИзменяетВыбранныеОбъекты = Истина;
	Команда.МножественныйВыбор = Ложь;
	Команда.Обработчик = "НастройкаПорядкаЭлементов.Подключаемый_ПереместитьЭлемент";
	Команда.ОтображениеКнопки = ОтображениеКнопки.Картинка;
	Команда.Назначение = "ДляСписка";
	
	Команда = Команды.Добавить();
	Команда.Вид = "НастройкаПорядкаЭлементов";
	Команда.Идентификатор = "Вниз";
	Команда.Представление = НСтр("ru = 'Переместить элемент вниз'");
	Команда.Порядок = 2;
	Команда.Картинка = БиблиотекаКартинок.ПереместитьВниз;
	Команда.ИзменяетВыбранныеОбъекты = Истина;
	Команда.МножественныйВыбор = Ложь;
	Команда.Обработчик = "НастройкаПорядкаЭлементов.Подключаемый_ПереместитьЭлемент";
	Команда.ОтображениеКнопки = ОтображениеКнопки.Картинка;
	Команда.Назначение = "ДляСписка";
	
КонецПроцедуры

#КонецОбласти

#Область СлужебныеПроцедурыИФункции

Функция УОбъектаЕстьРеквизитДопУпорядочивания(Объект, Информация)
	
	Если Не Информация.ЕстьРодитель Тогда
		// Справочник неиерархический, значит реквизит есть.
		Возврат Истина;
		
	ИначеЕсли Объект.ЭтоГруппа И Не Информация.ДляГрупп Тогда
		// Это группа, но для группа порядок не назначается.
		Возврат Ложь;
		
	ИначеЕсли Не Объект.ЭтоГруппа И Не Информация.ДляЭлементов Тогда
		// Это элемент, но для элементов порядок не назначается.
		Возврат Ложь;
		
	Иначе
		Возврат Истина;
		
	КонецЕсли;
	
КонецФункции

#КонецОбласти
