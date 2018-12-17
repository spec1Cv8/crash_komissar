///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2018, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

#Область ПрограммныйИнтерфейс

// Принимает в качестве параметра форму объекта, к которому подключена подсистема,
// и запрещает редактирование заданных реквизитов,
// а также добавляет во "Все действия" команду для разрешения их редактирования.
//
// Параметры:
//  Форма                   - УправляемаяФорма - форма объекта.
//  ГруппаДляКнопкиЗапрета  - ГруппаФормы - переопределяет стандартное размещение
//                            кнопки запрета в форме объекта.
//  ЗаголовокКнопкиЗапрета  - Строка - заголовок кнопки. По умолчанию, "Разрешить редактирование реквизитов".
//  Объект                  - Неопределено - взять объект из реквизита формы "Объект".
//                          - ДанныеФормыСтруктура - по типу объекта.
//
Процедура ЗаблокироватьРеквизиты(Форма, ГруппаДляКнопкиЗапрета = Неопределено, ЗаголовокКнопкиЗапрета = "",
		Объект = Неопределено) Экспорт
	
	ОписаниеОбъекта = ?(Объект = Неопределено, Форма.Объект, Объект);
	
	// Определение, форма уже подготовлена при предыдущем вызове.
	ФормаПодготовлена = Ложь;
	РеквизитыФормы = Форма.ПолучитьРеквизиты();
	Для Каждого РеквизитФормы Из РеквизитыФормы Цикл
		Если РеквизитФормы.Имя = "ПараметрыЗапретаРедактированияРеквизитов" Тогда
			ФормаПодготовлена = Истина;
			Прервать;
		КонецЕсли;
	КонецЦикла;
	
	Если Не ФормаПодготовлена Тогда
		ЗапретРедактированияРеквизитовОбъектовСлужебный.ПодготовитьФорму(Форма,
			ОписаниеОбъекта.Ссылка, ГруппаДляКнопкиЗапрета, ЗаголовокКнопкиЗапрета);
	КонецЕсли;
	
	ЭтоНовыйОбъект = ОписаниеОбъекта.Ссылка.Пустая();
	
	// Блокировка редактирования элементов формы, связанных с заданными реквизитами.
	Для Каждого ОписаниеБлокируемогоРеквизита Из Форма.ПараметрыЗапретаРедактированияРеквизитов Цикл
		Для Каждого ОписаниеЭлементаФормы Из ОписаниеБлокируемогоРеквизита.БлокируемыеЭлементы Цикл
			
			ОписаниеБлокируемогоРеквизита.РедактированиеРазрешено =
				ОписаниеБлокируемогоРеквизита.ПравоРедактирования И ЭтоНовыйОбъект;
			
			ЭлементФормы = Форма.Элементы.Найти(ОписаниеЭлементаФормы.Значение);
			Если ЭлементФормы <> Неопределено Тогда
				Если ТипЗнч(ЭлементФормы) = Тип("ПолеФормы")
				   И ЭлементФормы.Вид <> ВидПоляФормы.ПолеНадписи
				 Или ТипЗнч(ЭлементФормы) = Тип("ТаблицаФормы") Тогда
					ЭлементФормы.ТолькоПросмотр = НЕ ОписаниеБлокируемогоРеквизита.РедактированиеРазрешено;
				Иначе
					ЭлементФормы.Доступность = ОписаниеБлокируемогоРеквизита.РедактированиеРазрешено;
				КонецЕсли;
			КонецЕсли;
		КонецЦикла;
	КонецЦикла;
	
	Если Форма.Элементы.Найти("РазрешитьРедактированиеРеквизитовОбъекта") <> Неопределено Тогда
		Форма.Элементы.РазрешитьРедактированиеРеквизитовОбъекта.Доступность = Истина;
	КонецЕсли;
	
КонецПроцедуры

#КонецОбласти
