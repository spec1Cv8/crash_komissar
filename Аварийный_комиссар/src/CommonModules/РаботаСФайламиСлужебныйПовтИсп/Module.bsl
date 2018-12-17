///////////////////////////////////////////////////////////////////////////////////////////////////////
// Copyright (c) 2018, ООО 1С-Софт
// Все права защищены. Эта программа и сопроводительные материалы предоставляются 
// в соответствии с условиями лицензии Attribution 4.0 International (CC BY 4.0)
// Текст лицензии доступен по ссылке:
// https://creativecommons.org/licenses/by/4.0/legalcode
///////////////////////////////////////////////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////////////////////////
// Подсистема "Файловые функции".
//
////////////////////////////////////////////////////////////////////////////////

#Область СлужебныеПроцедурыИФункции

////////////////////////////////////////////////////////////////////////////////
// Общие и персональные настройки работы с файлами.

// Возвращает структуру, содержащую ОбщиеНастройки и ПерсональныеНастройки.
Функция НастройкиРаботыСФайлами() Экспорт
	
	ОбщиеНастройки        = Новый Структура;
	ПерсональныеНастройки = Новый Структура;
	
	РаботаСФайламиСлужебный.ДобавитьНастройкиРаботыСФайлами(ОбщиеНастройки, ПерсональныеНастройки);
	
	ДобавитьНастройкиРаботыСФайлами(ОбщиеНастройки, ПерсональныеНастройки);
	
	Настройки = Новый Структура;
	Настройки.Вставить("ОбщиеНастройки",        ОбщиеНастройки);
	Настройки.Вставить("ПерсональныеНастройки", ПерсональныеНастройки);
	
	Возврат Настройки;
	
КонецФункции

// Устанавливает общие и персональные настройки файловых функций.
Процедура ДобавитьНастройкиРаботыСФайлами(ОбщиеНастройки, ПерсональныеНастройки)
	
	УстановитьПривилегированныйРежим(Истина);
	
	// Заполнение общих настроек.
	
	// ИзвлекатьТекстыФайловНаСервере.
	ОбщиеНастройки.Вставить(
		"ИзвлекатьТекстыФайловНаСервере", РаботаСФайламиСлужебный.ИзвлекатьТекстыФайловНаСервере());
	
	// МаксимальныйРазмерФайла.
	ОбщиеНастройки.Вставить("МаксимальныйРазмерФайла", РаботаСФайлами.МаксимальныйРазмерФайла());
	
	// ЗапрещатьЗагрузкуФайловПоРасширению.
	ЗапрещатьЗагрузкуФайловПоРасширению = Константы.ЗапрещатьЗагрузкуФайловПоРасширению.Получить();
	Если ЗапрещатьЗагрузкуФайловПоРасширению = Неопределено Тогда
		ЗапрещатьЗагрузкуФайловПоРасширению = Ложь;
		Константы.ЗапрещатьЗагрузкуФайловПоРасширению.Установить(ЗапрещатьЗагрузкуФайловПоРасширению);
	КонецЕсли;
	ОбщиеНастройки.Вставить("ЗапретЗагрузкиФайловПоРасширению", ЗапрещатьЗагрузкуФайловПоРасширению);
	
	// СписокЗапрещенныхРасширений.
	ОбщиеНастройки.Вставить("СписокЗапрещенныхРасширений", СписокЗапрещенныхРасширений());
	
	// СписокРасширенийФайловOpenDocument.
	ОбщиеНастройки.Вставить("СписокРасширенийФайловOpenDocument", СписокРасширенийФайловOpenDocument());
	
	// СписокРасширенийТекстовыхФайлов.
	ОбщиеНастройки.Вставить("СписокРасширенийТекстовыхФайлов", СписокРасширенийТекстовыхФайлов());
	
	// Заполнение персональных настроек.
	
	// МаксимальныйРазмерЛокальногоКэшаФайлов.
	МаксимальныйРазмерЛокальногоКэшаФайлов = ОбщегоНазначения.ХранилищеОбщихНастроекЗагрузить(
		"ЛокальныйКэшФайлов", "МаксимальныйРазмерЛокальногоКэшаФайлов");
	
	Если МаксимальныйРазмерЛокальногоКэшаФайлов = Неопределено Тогда
		МаксимальныйРазмерЛокальногоКэшаФайлов = 100*1024*1024; // 100 МБ.
		
		ОбщегоНазначения.ХранилищеОбщихНастроекСохранить(
			"ЛокальныйКэшФайлов",
			"МаксимальныйРазмерЛокальногоКэшаФайлов",
			МаксимальныйРазмерЛокальногоКэшаФайлов);
	КонецЕсли;
	
	ПерсональныеНастройки.Вставить(
		"МаксимальныйРазмерЛокальногоКэшаФайлов",
		МаксимальныйРазмерЛокальногоКэшаФайлов);
	
	// ПутьКЛокальномуКэшуФайлов.
	ПутьКЛокальномуКэшуФайлов = ОбщегоНазначения.ХранилищеОбщихНастроекЗагрузить(
		"ЛокальныйКэшФайлов", "ПутьКЛокальномуКэшуФайлов");
	// Не следует получать эту переменную непосредственно.
	// Нужно использовать функцию РабочийКаталогПользователя
	// модуля РаботаСФайламиСлужебныйКлиент.
	ПерсональныеНастройки.Вставить("ПутьКЛокальномуКэшуФайлов", ПутьКЛокальномуКэшуФайлов);
	
	// УдалятьФайлИзЛокальногоКэшаФайловПриЗавершенииРедактирования.
	УдалятьФайлИзЛокальногоКэшаФайловПриЗавершенииРедактирования =
		ОбщегоНазначения.ХранилищеОбщихНастроекЗагрузить(
			"ЛокальныйКэшФайлов", "УдалятьФайлИзЛокальногоКэшаФайловПриЗавершенииРедактирования");
	
	Если УдалятьФайлИзЛокальногоКэшаФайловПриЗавершенииРедактирования = Неопределено Тогда
		УдалятьФайлИзЛокальногоКэшаФайловПриЗавершенииРедактирования = Ложь;
	КонецЕсли;
	
	ПерсональныеНастройки.Вставить(
		"УдалятьФайлИзЛокальногоКэшаФайловПриЗавершенииРедактирования",
		УдалятьФайлИзЛокальногоКэшаФайловПриЗавершенииРедактирования);
	
	// ПодтверждатьПриУдаленииИзЛокальногоКэшаФайлов.
	ПодтверждатьПриУдаленииИзЛокальногоКэшаФайлов =
		ОбщегоНазначения.ХранилищеОбщихНастроекЗагрузить(
			"ЛокальныйКэшФайлов", "ПодтверждатьПриУдаленииИзЛокальногоКэшаФайлов");
	
	Если ПодтверждатьПриУдаленииИзЛокальногоКэшаФайлов = Неопределено Тогда
		ПодтверждатьПриУдаленииИзЛокальногоКэшаФайлов = Ложь;
	КонецЕсли;
	
	ПерсональныеНастройки.Вставить(
		"ПодтверждатьПриУдаленииИзЛокальногоКэшаФайлов",
		ПодтверждатьПриУдаленииИзЛокальногоКэшаФайлов);
	
	// ПоказыватьПодсказкиПриРедактированииФайлов.
	ПоказыватьПодсказкиПриРедактированииФайлов = ОбщегоНазначения.ХранилищеОбщихНастроекЗагрузить(
		"НастройкиПрограммы", "ПоказыватьПодсказкиПриРедактированииФайлов");
	
	Если ПоказыватьПодсказкиПриРедактированииФайлов = Неопределено Тогда
		ПоказыватьПодсказкиПриРедактированииФайлов = Истина;
		
		ОбщегоНазначения.ХранилищеОбщихНастроекСохранить(
			"НастройкиПрограммы",
			"ПоказыватьПодсказкиПриРедактированииФайлов",
			ПоказыватьПодсказкиПриРедактированииФайлов);
	КонецЕсли;
	ПерсональныеНастройки.Вставить(
		"ПоказыватьПодсказкиПриРедактированииФайлов",
		ПоказыватьПодсказкиПриРедактированииФайлов);
	
	// ПоказыватьИнформациюЧтоФайлНеБылИзменен.
	ПоказыватьИнформациюЧтоФайлНеБылИзменен = ОбщегоНазначения.ХранилищеОбщихНастроекЗагрузить(
		"НастройкиПрограммы", "ПоказыватьИнформациюЧтоФайлНеБылИзменен");
	
	Если ПоказыватьИнформациюЧтоФайлНеБылИзменен = Неопределено Тогда
		ПоказыватьИнформациюЧтоФайлНеБылИзменен = Истина;
		
		ОбщегоНазначения.ХранилищеОбщихНастроекСохранить(
			"НастройкиПрограммы",
			"ПоказыватьИнформациюЧтоФайлНеБылИзменен",
			ПоказыватьИнформациюЧтоФайлНеБылИзменен);
	КонецЕсли;
	ПерсональныеНастройки.Вставить(
		"ПоказыватьИнформациюЧтоФайлНеБылИзменен",
		ПоказыватьИнформациюЧтоФайлНеБылИзменен);
	
	// Настройки открытия файлов.
	ТекстовыеФайлыРасширение = ОбщегоНазначения.ХранилищеОбщихНастроекЗагрузить(
		"НастройкиОткрытияФайлов\ТекстовыеФайлы",
		"Расширение", "TXT XML INI");
	
	ТекстовыеФайлыСпособОткрытия = ОбщегоНазначения.ХранилищеОбщихНастроекЗагрузить(
		"НастройкиОткрытияФайлов\ТекстовыеФайлы", 
		"СпособОткрытия",
		Перечисления.СпособыОткрытияФайлаНаПросмотр.ВоВстроенномРедакторе);
	
	ГрафическиеСхемыРасширение = ОбщегоНазначения.ХранилищеОбщихНастроекЗагрузить(
		"НастройкиОткрытияФайлов\ГрафическиеСхемы", "Расширение", "GRS");
	
	ГрафическиеСхемыСпособОткрытия = ОбщегоНазначения.ХранилищеОбщихНастроекЗагрузить(
		"НастройкиОткрытияФайлов\ГрафическиеСхемы",
		"СпособОткрытия",
		Перечисления.СпособыОткрытияФайлаНаПросмотр.ВоВстроенномРедакторе);
	
	ПерсональныеНастройки.Вставить("ТекстовыеФайлыРасширение",       ТекстовыеФайлыРасширение);
	ПерсональныеНастройки.Вставить("ТекстовыеФайлыСпособОткрытия",   ТекстовыеФайлыСпособОткрытия);
	ПерсональныеНастройки.Вставить("ГрафическиеСхемыРасширение",     ГрафическиеСхемыРасширение);
	ПерсональныеНастройки.Вставить("ГрафическиеСхемыСпособОткрытия", ГрафическиеСхемыСпособОткрытия);
	
КонецПроцедуры

Функция СписокЗапрещенныхРасширений()
	
	УстановитьПривилегированныйРежим(Истина);
	
	СписокЗапрещенныхРасширенийОбластиДанных =
		Константы.СписокЗапрещенныхРасширенийОбластиДанных.Получить();
	
	Если СписокЗапрещенныхРасширенийОбластиДанных = Неопределено
	 ИЛИ СписокЗапрещенныхРасширенийОбластиДанных = "" Тогда
		
		СписокЗапрещенныхРасширенийОбластиДанных = "COM EXE BAT CMD VBS VBE JS JSE WSF WSH SCR";
		
		Константы.СписокЗапрещенныхРасширенийОбластиДанных.Установить(
			СписокЗапрещенныхРасширенийОбластиДанных);
	КонецЕсли;
	
	ИтоговыйСписокРасширений = "";
	
	Если ОбщегоНазначения.РазделениеВключено()
	   И ОбщегоНазначения.ДоступноИспользованиеРазделенныхДанных() Тогда
		
		СписокЗапрещенныхРасширений = Константы.СписокЗапрещенныхРасширений.Получить();
		
		ИтоговыйСписокРасширений = 
			СписокЗапрещенныхРасширений + " "  + СписокЗапрещенныхРасширенийОбластиДанных;
	Иначе
		ИтоговыйСписокРасширений = СписокЗапрещенныхРасширенийОбластиДанных;
	КонецЕсли;
		
	Возврат ИтоговыйСписокРасширений;
	
КонецФункции

Функция СписокРасширенийФайловOpenDocument()
	
	УстановитьПривилегированныйРежим(Истина);
	
	СписокРасширенийФайловOpenDocumentОбластиДанных =
		Константы.СписокРасширенийФайловOpenDocumentОбластиДанных.Получить();
	
	Если СписокРасширенийФайловOpenDocumentОбластиДанных = Неопределено
	 ИЛИ СписокРасширенийФайловOpenDocumentОбластиДанных = "" Тогда
		
		СписокРасширенийФайловOpenDocumentОбластиДанных =
			"ODT OTT ODP OTP ODS OTS ODC OTC ODF OTF ODM OTH SDW STW SXW STC SXC SDC SDD STI";
		
		Константы.СписокРасширенийФайловOpenDocumentОбластиДанных.Установить(
			СписокРасширенийФайловOpenDocumentОбластиДанных);
	КонецЕсли;
	
	ИтоговыйСписокРасширений = "";
	
	Если ОбщегоНазначения.РазделениеВключено()
	   И ОбщегоНазначения.ДоступноИспользованиеРазделенныхДанных() Тогда
		
		СписокЗапрещенныхРасширений = Константы.СписокРасширенийФайловOpenDocument.Получить();
		
		ИтоговыйСписокРасширений =
			СписокЗапрещенныхРасширений + " "  + СписокРасширенийФайловOpenDocumentОбластиДанных;
	Иначе
		ИтоговыйСписокРасширений = СписокРасширенийФайловOpenDocumentОбластиДанных;
	КонецЕсли;
	
	Возврат ИтоговыйСписокРасширений;
	
КонецФункции

Функция СписокРасширенийТекстовыхФайлов()

	УстановитьПривилегированныйРежим(Истина);
	
	СписокРасширенийТекстовыхФайлов = Константы.СписокРасширенийТекстовыхФайлов.Получить();
	
	Если ПустаяСтрока(СписокРасширенийТекстовыхФайлов) Тогда
		СписокРасширенийТекстовыхФайлов = "TXT";
	КонецЕсли;
	
	Возврат СписокРасширенийТекстовыхФайлов;

КонецФункции

// Возвращает признак принадлежности узла к плану обмена РИБ.
//
// Параметры:
//  ПолноеИмяПланаОбмена - Строка - плана обмена, для которого требуется получить значение функции.
// 
//  Возвращаемое значение:
//   Истина - узел принадлежит плану обмена РИБ, иначе Ложь.
//
Функция ЭтоУзелРаспределеннойИнформационнойБазы(ПолноеИмяПланаОбмена) Экспорт

	Возврат Метаданные.НайтиПоПолномуИмени(ПолноеИмяПланаОбмена).РаспределеннаяИнформационнаяБаза;
	
КонецФункции

#КонецОбласти
