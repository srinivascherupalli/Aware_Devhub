import { LightningElement, track, api, wire } from "lwc";
import { ShowToastEvent } from 'lightning/platformShowToastEvent';
const l10n = {
    weekdays: {
        shorthand: ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"],
        longhand: [
            "Sunday",
            "Monday",
            "Tuesday",
            "Wednesday",
            "Thursday",
            "Friday",
            "Saturday"
        ]
    },
    months: {
        shorthand: [
            "Jan",
            "Feb",
            "Mar",
            "Apr",
            "May",
            "Jun",
            "Jul",
            "Aug",
            "Sep",
            "Oct",
            "Nov",
            "Dec"
        ],
        longhand: [
            "January",
            "February",
            "March",
            "April",
            "May",
            "June",
            "July",
            "August",
            "September",
            "October",
            "November",
            "December"
        ]
    },
    daysInMonth: [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31],
    firstDayOfWeek: 0
};

export default class Calendar extends LightningElement {
    options = [];
    date;
    month;
    year;
    minDate;
    selectedDate;
    weekNameArray = l10n.weekdays.shorthand;
    keyValue = {
        startDate: {
            value: "",
            month: 0,
            year: 0,
            date: 0
        },
        endDate: {
            value: "",
            month: 0,
            year: 0,
            date: 0
        }
    };

    @track dAW = [];
    @api daysInput;

    date = {
        current: {
            year: function () {
                return new Date().getFullYear();
            },
            month: {
                integer: function () {
                    return new Date().getMonth();
                }
            },
            day: function () {
                return new Date().getDate();
            }
        }
    };

    connectedCallback() {
        var currentDate;
        try {
            this.dAW = this.generatedAW();
            currentDate = new Date();
            this.setDateValues(currentDate, currentDate.getDate());
            this.generateYearOptions();
            this.generateMonth();
            this.date = currentDate.getDate();
        } catch (Err) {
            this.showToast('Error in JS', "Error in connectedCallback Method :" + Err, 'error', '');
        }
    }

    goToPreviousMonth() {
        this.changeMonth(-1);
        return false;
    }

    goToNextMonth() {
        this.changeMonth(1);
        return false;
    }

    handleYearChange(event) {
        var newYear;
        var date;
        var currentMonth;
        var currentYear;
        var currentDate;
        var targetDate;
        var daysInMonth;
        try {
            newYear = event.currentTarget.value;
            date = this.date;
            currentMonth = this.month;
            currentYear = this.year;
            if (!currentYear) {
                currentYear = this.date.current.year();
            }
            currentDate = new Date(currentYear, currentMonth, date);
            targetDate = new Date(newYear, currentDate.getMonth(), 1);
            daysInMonth = this.numDays(currentMonth, currentYear);
            if (daysInMonth < date) {
                // The target month doesn't have the current date. Just set it to the last date.
                date = daysInMonth;
            }
            this.setDateValues(targetDate, date);
            this.generateMonth();
        } catch (Err) {
            this.showToast('Error in JS', "Error in yearChange Method :" + Err, 'error', '');
        }
    }

    changeMonth(monthChange) {
        var currentYear;
        var currentMonth;
        var currentDay;
        var currentDate;
        var targetDate;
        var daysInMonth;
        try {
            currentYear = this.year;
            currentMonth = this.month;
            currentDay = this.date;
            currentDate = new Date(currentYear, currentMonth, currentDay);
            targetDate = new Date(
                currentDate.getFullYear(),
                currentDate.getMonth() + monthChange,
                1
            );
            daysInMonth = this.numDays(currentMonth, currentYear);
            if (daysInMonth < currentDay) {
                // The target month doesn't have the current date. Just set it to the last date.
                currentDay = daysInMonth;
            }
            this.setDateValues(targetDate, currentDay);
            this.generateMonth();
        } catch (Err) {
            this.showToast('Error in JS', "Error in changeMonth Method :" + Err, 'error', '');
        }
    }

    goToToday() {
        var currentYear;
        var currentMonth;
        var currentDay;
        var targetDate;
        var keyV = this.keyValue;
        var todayV;
        try {
            currentYear = new Date().getFullYear();
            currentMonth = parseInt(new Date().getMonth(), 10);
            currentDay = new Date().getDate();
            this.options.forEach(opt => {
                opt.selected = false;
                // eslint-disable-next-line eqeqeq
                if (opt ? opt.value == currentYear : false) {
                    opt.selected = true;
                }
            });
            targetDate = new Date(currentYear, currentMonth, currentDay);
            this.setDateValues(targetDate, currentDay);
            todayV =
                currentYear +
                "-" +
                ("0" + (currentMonth + 1)).slice(-2) +
                "-" +
                ("0" + currentDay).slice(-2);
            keyV.startDate.value = keyV.endDate.value = todayV;
            keyV.startDate.month = keyV.endDate.month = currentMonth + 1;
            keyV.startDate.year = keyV.endDate.year = currentYear;
            keyV.startDate.date = keyV.endDate.date = currentDay;
            this.keyValue = keyV;
            this.generateMonth();
        } catch (Err) {
            this.showToast('Error in JS', "Error in goToToday Method :" + Err, 'error', '');
        }
    }

    generateYearOptions() {
        var dt;
        var startY;
        var endY;
        var years = [];
        var i;
        try {
            dt = new Date();
            startY = dt.getFullYear();
            endY = startY + 5;
            years = [];
            i = startY - 1;
            for (; i <= endY; i++) {
                years.push({ label: i, value: i, selected: i === startY });
            }
            this.options = years;
        } catch (Err) {
            this.showToast('Error in JS', "Error in generateYearOptions Method :" + Err, 'error', '');
        }
    }

    /**
     * Java style date comparisons. Compares by day, month, and year only.
     */
    dateEquals(date1, date2) {
        return date1 && date2 ? this.dateCompare(date1, date2) === 0 : false;
    }

    dateLessEquals(date1, date2) {
        return date1 && date2 ? this.dateCompare(date1, date2) <= 0 : false;
    }

    dateLess(date1, date2) {
        return date1 && date2 ? this.dateCompare(date1, date2) < 0 : false;
    }

    dateCompare(date1, date2) {
        var intVal = 0;
        try {
            if (date1.getFullYear() !== date2.getFullYear()) {
                intVal = date1.getFullYear() - date2.getFullYear();
            } else {
                if (date1.getMonth() !== date2.getMonth()) {
                    intVal = date1.getMonth() - date2.getMonth();
                } else {
                    intVal = date1.getDate() - date2.getDate();
                }
            }
        } catch (Err) {
            this.showToast('Error in JS', "Error in dateCompare Method :" + Err, 'error', '');
        }
        return intVal;
    }
    /**
     * generates the days for the current selected month.
     */
    generateMonth() {
        //var dayOfMonth = this.date;
        var month = this.month;
        var year = this.year;
        var minDate = this.minDate;
        var today = new Date();
        var d = new Date();
        var firstDayOfWeek = 0;
        var startDay;
        var i = 0;
        var j = 0;
        var k = 0;
        var tdClass;
        var dateStr;
        var array1 = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10];
        var weekRem = 0;
        var dAW = this.dAW;
        var keyV = this.keyValue;

        try {
            d.setDate(1);
            d.setFullYear(year);
            d.setMonth(month);
            // java days are indexed from 1-7, javascript 0-6
            // The startPoint will indicate the first date displayed at the top-left
            // corner of the calendar. Negative dates in JS will subtract days from
            // the 1st of the given month
            firstDayOfWeek = 0; // In Java, week day is 1 - 7
            startDay = d.getDay();
            while (startDay !== firstDayOfWeek) {
                d.setDate(d.getDate() - 1);
                startDay = d.getDay();
            }
            for (; i <= 41; i++) {
                weekRem = i / 7;

                if (array1.includes(weekRem)) {
                    j++;
                    k = 0;
                }
                if (dAW[j].days[k]) {
                    tdClass = "";
                    console.log(this.daysInput);
                    var disableDaysOfWeek = this.daysInput;
                    var currentDayOfWeek = d.getDay();

                    if(disableDaysOfWeek.indexOf((d.getDay()).toString()) == -1) {
                        dAW[j].days[k].ariaDisabled = true;
                        tdClass = "slds-disabled-text";
                    }
                    if(d<today) {
                        //dAW[j].days[k].ariaDisabled = true;
                        tdClass = "slds-disabled-text";
                    }
                    if (d.getMonth() === month - 1 || d.getFullYear() === year - 1) {
                        dAW[j].days[k].ariaDisabled = true;
                        tdClass = "slds-disabled-text";
                    } else if (
                        d.getMonth() === month + 1 ||
                        d.getFullYear() === year + 1
                    ) {
                        dAW[j].days[k].ariaDisabled = true;
                        tdClass = "slds-disabled-text";
                    }
                    if (this.dateEquals(d, today)) {
                        tdClass += " slds-is-today";
                    }
                    if (
                        keyV.startDate.value && keyV.startDate.value
                            ? keyV.startDate.value === keyV.endDate.value
                                ? this.dateEquals(
                                    d,
                                    new Date(
                                        keyV.startDate.year,
                                        keyV.startDate.month - 1,
                                        keyV.startDate.date
                                    )
                                )
                                : false
                            : false
                    ) {
                        dAW[j].days[k].ariaSelected = true;
                        tdClass += " slds-is-selected";
                    } else if (
                        keyV.startDate.value
                            ? this.dateEquals(
                                d,
                                new Date(
                                    keyV.startDate.year,
                                    keyV.startDate.month - 1,
                                    keyV.startDate.date
                                )
                            )
                                ? true
                                : keyV.endDate.value
                                    ? this.dateLessEquals(
                                        d,
                                        new Date(
                                            keyV.endDate.year,
                                            keyV.endDate.month - 1,
                                            keyV.endDate.date
                                        )
                                    )
                                        ? !this.dateLessEquals(
                                            d,
                                            new Date(
                                                keyV.startDate.year,
                                                keyV.startDate.month - 1,
                                                keyV.startDate.date
                                            )
                                        )
                                        : false
                                    : false
                            : false
                    ) {
                        dAW[j].days[k].ariaSelected = true;
                        tdClass += " slds-is-selected slds-is-selected-multi";
                        if (!dAW[j].trClass) {
                            dAW[j].trClass =
                                "slds-has-multi-selection slds-has-multi-row-selection";
                        }
                    }
                    if (minDate && minDate.getTime() > d.getTime()) {
                        dAW[j].days[k].ariaDisabled = true;
                        tdClass = "slds-disabled-text";
                    }
                    dAW[j].days[k].label = d.getDate();
                    dAW[j].days[k].tdClass = tdClass;
                    dateStr =
                        d.getFullYear() +
                        "-" +
                        ("0" + (d.getMonth() + 1)).slice(-2) +
                        "-" +
                        ("0" + d.getDate()).slice(-2);
                    dAW[j].days[k].value = dateStr;
                }
                d.setDate(d.getDate() + 1);
                k++;
            }
            this.dAW = dAW;
        } catch (Err) {
            this.showToast('Error in JS', "Error in generateMonth Method :" + Err, 'error', '');
        }
    }

    setDateValues(fullDate, dateNum) {
        try {
            this.year = fullDate.getFullYear();
            this.month = fullDate.getMonth();
            this.monthName = l10n.months.longhand[fullDate.getMonth()];
            this.date = dateNum;
            this.selectedDate = fullDate;
        } catch (Err) {
            this.showToast('Error in JS', "Error in setDateValues Method :" + Err, 'error', '');
        }
    }
    numDays(currentMonth, currentYear) {
        // checks to see if february is a leap year otherwise return the respective # of days
        return currentMonth === 1 &&
            ((currentYear % 4 === 0 && currentYear % 100 !== 0) ||
                currentYear % 400 === 0)
            ? 29
            : l10n.daysInMonth[currentMonth];
    }
    handleCellClick(event) {
        var theTarget;
        var key;
        var dateValue;
        var disabledFlag;
        var today = new Date();
        try {
            theTarget = event.target;
            key = theTarget.getAttribute("data-id");
            dateValue = theTarget.getAttribute("data-value");
            
            disabledFlag = theTarget.getAttribute("data-disabled");
            if (disabledFlag ? disabledFlag === "true" : false) {
                // do Nothing Just Return
                return;
            }
            let yesterday = new Date();
            yesterday.setDate(today.getDate() - 1);
            var formatedSelectedDate = new Date(dateValue);
            if (key && dateValue && (formatedSelectedDate>yesterday)) {
                this.handleSelect(dateValue);
            }
        } catch (Err) {
            console.log(Err);
            this.showToast('Error in JS', "Error in handleCellClick Method :" + Err, 'error', '');
        }
    }

    handleSelect(dateValue) {
        var keyValue;
        var strArry = [];
        try {
            keyValue = this.keyValue;
            strArry = dateValue.split("-");
            if (
                keyValue.startDate.value
                    ? keyValue.startDate.value
                        ? true
                        : this.dateLess(
                            new Date(strArry[0], strArry[1] - 1, strArry[2]),
                            new Date(
                                keyValue.startDate.year,
                                keyValue.startDate.month - 1,
                                keyValue.startDate.date
                            )
                        )
                    : true
            ) {
                keyValue.startDate.value = dateValue;
                keyValue.startDate.date = strArry[2];
                keyValue.startDate.month = strArry[1];
                keyValue.startDate.year = strArry[0];
                keyValue.endDate.value = "";
                keyValue.endDate.date = 0;
                keyValue.endDate.month = 0;
                keyValue.endDate.year = 0;
            } else if (keyValue.startDate.value && !keyValue.endDate.value) {
                keyValue.endDate.value = dateValue;
                keyValue.endDate.date = strArry[2];
                keyValue.endDate.month = strArry[1];
                keyValue.endDate.year = strArry[0];
            }
            this.keyValue = keyValue;

            const selectedEvent = new CustomEvent('keyvaluechange', {
                detail:this.keyValue.startDate.value
            });
            this.dispatchEvent(selectedEvent);

            this.generateMonth();
        } catch (Err) {
            this.showToast('Error in JS', "Error in handleSelect Method :" + Err, 'error', '');
        }
    }
    showToast(title, message, variant, mode) {
        var event = new ShowToastEvent({
            title: title,
            message: message,
            variant: variant,
            mode: (mode) ? mode : 'dismissable'
        });
        this.dispatchEvent(event);
    }

    generatedAW() {
        var tempArry = [];
        var tempdays = [];
        var i = 1;
        var j = 0;
        for (; i <= 6; i++) {
            tempdays = [];
            for (; j <= ((7 * i) - 1); j++) {
                tempdays.push({
                    label: "",
                    key: j,
                    ariaDisabled: false,
                    ariaSelected: false,
                    tdClass: "",
                    value: ""
                });
            }
            tempArry.push({
                name: "week" + i,
                trClass: "",
                days: tempdays
            });
        }
        return tempArry;
    }
}