﻿; (function ($) {
    /**
     * jqGrid Arabic Translation
     * 
     * http://trirand.com/blog/ 
     * Dual licensed under the MIT and GPL licenses:
     * http://www.opensource.org/licenses/mit-license.php
     * http://www.gnu.org/licenses/gpl.html
    **/
    $.jgrid = $.jgrid || {};
    $.extend($.jgrid, {
        defaults: {
            recordtext: "تسجيل {0} - {1} على {2}",
            emptyrecords: "لا يوجد سجلات",
            loadtext: "...يرجى الإنتظار", /* @Mohammad Alqerm at Octtober 13, 2015, 10:51 AM */
            pgtext: "صفحة {0} على {1}"
        },
        search: {
            caption: "بحث...",
            Find: "بحث",
            Reset: "إلغاء",
            odata: [{ oper: 'eq', text: "يساوي" }, { oper: 'ne', text: "يختلف" }, { oper: 'lt', text: "أقل" }, { oper: 'le', text: "أقل أو يساوي" }, { oper: 'gt', text: "أكبر" }, { oper: 'ge', text: "أكبر أو يساوي" }, { oper: 'bw', text: "يبدأ بـ" }, { oper: 'bn', text: "لا يبدأ بـ" }, { oper: 'ew', text: "ينته بـ" }, { oper: 'en', text: "لا ينته بـ" }, { oper: 'cn', text: "يحتوي" }, { oper: 'nc', text: "لا يحتوي" }],
            groupOps: [{ op: "مع", text: "الكل" }, { op: "أو", text: "لا أحد" }],
            operandTitle: ".اختر عملية البحث",
            resetTitle: "تفريخ خانات البحث"
        },
        edit: {
            addCaption: "اضافة مرحلة",
            editCaption: "تحديث مرحلة",
            bSubmit: "حفظ مرحلة",
            bCancel: "إلغاء",
            bClose: "إغلاق",
            saveData: "هل تريد حفظ التعديلات ؟",
            bYes: "نعم",
            bNo: "لا",
            bExit: "إلغاء",
            msg: {
                required: "حقول إجبارية",
                number: "سجل رقم صحيح",
                minValue: "يجب أن تكون القيمة أكبر أو تساوي 0",
                maxValue: "يجب أن تكون القيمة أقل أو تساوي 0",
                email: "بريد غير صحيح",
                integer: "سجل عدد طبييعي صحيح",
                url: "ليس عنوانا صحيحا. البداية الصحيحة ('http://' أو 'https://')",
                nodefined: " ليس محدد!",
                novalue: " قيمة الرجوع مطلوبة!",
                customarray: "يجب على الدالة الشخصية أن تنتج جدولا",
                customfcheck: "الدالة الشخصية مطلوبة في حالة التحقق الشخصي"
            }
        },
        view: {
            caption: "تفاصيل المرحلة",
            bClose: "غلق"
        },
        del: {
            caption: "حذف",
            msg: "حذف المنافذ المختارة ؟",
            bSubmit: "حذف",
            bCancel: "إلغاء"
        },
        nav: {
            edittext: " ",
            edittitle: "تغيير المرحلة المختار",
            addtext: " ",
            addtitle: "إضافة مرحلة",
            deltext: " ",
            deltitle: "حذف المرحلة المختارة",
            searchtext: " ",
            searchtitle: "بحث عن مرحلة",
            refreshtext: "",
            refreshtitle: "تحديث الجدول",
            alertcap: "تحذير",
            alerttext: "يرجى إختيار مرحلة",
            viewtext: "",
            viewtitle: "إظهار مرحلة المختار"
        },
        col: {
            caption: "إظهار/إخفاء الأعمدة",
            bSubmit: "تثبيث",
            bCancel: "إلغاء"
        },
        errors: {
            errcap: "خطأ",
            nourl: "لا يوجد عنوان محدد",
            norecords: "لا يوجد تسجيل للمعالجة",
            model: "عدد عناوين المراحل (colNames) <> عدد المراحل (colModel)!"
        },
        formatter: {
            integer: { thousandsSeparator: " ", defaultValue: '0' },
            number: { decimalSeparator: ",", thousandsSeparator: " ", decimalPlaces: 2, defaultValue: '0,00' },
            currency: { decimalSeparator: ",", thousandsSeparator: " ", decimalPlaces: 2, prefix: "", suffix: "", defaultValue: '0,00' },
            date: {
                dayNames: [
                    "الأحد", "الإثنين", "الثلاثاء", "الأربعاء", "الخميس", "الجمعة", "السبت",
                    "الأحد", "الإثنين", "الثلاثاء", "الأربعاء", "الخميس", "الجمعة", "السبت"
                ],
                monthNames: [
                    "جانفي", "فيفري", "مارس", "أفريل", "ماي", "جوان", "جويلية", "أوت", "سبتمبر", "أكتوبر", "نوفمبر", "ديسمبر",
                    "جانفي", "فيفري", "مارس", "أفريل", "ماي", "جوان", "جويلية", "أوت", "سبتمبر", "أكتوبر", "نوفمبر", "ديسمبر"
                ],
                AmPm: ["ص", "م", "ص", "م"],
                S: function (j) { return j == 1 ? 'er' : 'e'; },
                srcformat: 'Y-m-d',
                newformat: 'd/m/Y',
                parseRe: /[#%\\\/:_;.,\t\s-]/,
                masks: {
                    ISO8601Long: "Y-m-d H:i:s",
                    ISO8601Short: "Y-m-d",
                    ShortDate: "n/j/Y",
                    LongDate: "l, F d, Y",
                    FullDateTime: "l, F d, Y g:i:s A",
                    MonthDay: "F d",
                    ShortTime: "g:i A",
                    LongTime: "g:i:s A",
                    SortableDateTime: "Y-m-d\\TH:i:s",
                    UniversalSortableDateTime: "Y-m-d H:i:sO",
                    YearMonth: "F, Y"
                },
                reformatAfterEdit: false
            },
            baseLinkUrl: '',
            showAction: '',
            target: '',
            checkbox: { disabled: true },
            idName: 'id'
        }
    });
})(jQuery);
