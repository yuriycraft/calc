#!/usr/bin/env xcrun swift
import Foundation

let operationsDict = [
    "+": (priority: 2, rightAssociate: false),
    "-": (priority: 2, rightAssociate: false),
    "*": (priority: 3, rightAssociate: false),
    "/": (priority: 3, rightAssociate: false),
    "s": (priority: 3, rightAssociate: true),
    "c": (priority: 3, rightAssociate: true),
    "x": (priority: 3, rightAssociate: true),
    "^": (priority: 4, rightAssociate: true),
]

func rpn(inputString: [String]) -> [String] {
    
    if inputString.isEmpty {
        error(nil)
    }
    var rpn : [String] = [] // выходной массив
    var stackOper : [String] = [] // стек операторов , левой скобки и функций
    
    for token in inputString {
        switch token {
        case "(":
            stackOper += [token] // если токен является открывающей скобкой, помещаем его в стек
        case ")" : // если токен является закрывающей скобкой
            while !stackOper.isEmpty {
                let op = stackOper.removeLast() // выталкиваем элементы из стека
                if op == "(" {
                    break // прерываем цикл т.к "("
                } else {
                    rpn += [op] // добавляем извлеченный из стека токен в выходную строку
                }
            }
        default: if let o1 = operationsDict[token] { // если токен является оператором
            for op in stackOper.reverse() {
                if let o2 = operationsDict[op] {
                    if !(o1.priority > o2.priority || (o1.priority == o2.priority && o1.rightAssociate)) {
                        rpn += [stackOper.removeLast()] // выталкиваем верхние элементы стека в выходную строку
                        continue
                    }
                }
                break
            }
            stackOper += [token] // помещаем оператор в стек.
        } else { // если токен не оператор
            rpn += [token] // добавляем токен в выходную строку
            }
        }
    }
    return rpn + stackOper.reverse()
}

func normal(inputString:String) -> String {
    
    if inputString.isEmpty {
        error(nil)
    }
    let tokenDict = [
        " "   : "" ,
        "exp" : "x" ,
        "\n"  : "" ,
        "sin" : "s" ,
        "cos" : "c" ,
        "pi"  : "3,14159265358979" ,
        "e"   : "2,71828182845905" ,
        "."   : "," ,
        "(-"  : "(0-" ,
    ]
    var expressionString = inputString.lowercaseString
    
    for token in tokenDict{
        expressionString = expressionString.stringByReplacingOccurrencesOfString(token.0, withString:token.1)
    }
    if expressionString[expressionString.startIndex] == "-" {
        expressionString = "0" + expressionString
    }
    let ch : Character = " "
    var resultString = String ()
    for i in expressionString {  // расставляем пробелы
        switch i {
        case "+","*","-","/","(",")","^" : resultString.append(ch)
        resultString.append(i)
        resultString.append(ch)
        default : resultString.append(i)
            continue
        }
    }
    //xCode 6.1.1
    //return join(" ",rpn(split(resultString , { $0 == " " })))
    
    //xCode 6.3
    return join(" " , rpn(split(resultString) { $0 == " " }))
}

func stringToDouble (inputString : String) -> Double { // конвертируем  String в Double
    
    if inputString.isEmpty {
        error(nil)
    }
    return NSNumberFormatter().numberFromString(inputString)!.doubleValue
}

func isNumber(inputString : String) -> Bool { // проверяем является ли String числом
    
    if inputString.isEmpty {
        error(nil)
    }
    var regex : String = "((-)?[0-9]\\d*(,\\d+)?)"
    var predicate = NSPredicate (format: "SELF MATCHES %@", regex)
    var isNum = predicate.evaluateWithObject(inputString)
    return isNum
}

func calculate(inputString : String) -> Double {
    
    if inputString.isEmpty {
        error(nil)
    }
    let rpnString : String = (normal(inputString)) //Дано выражение в ОПН
    var result : [Double] = []  // Массив для хранения результата
    var stackOper : String = String() // Стек для хранения смешанных данных (чисел и операторов)
    var op1 = Double ()
    var op2 = Double ()
    
    for element in rpnString { // Пытаемся распознать текущий аргумент как число или символ арифметической операции
        switch element {
        case "*" : if result.count >= 2 {
            result += [result.removeLast() * result.removeLast()]
        } else {
            error(nil)
            }
        case "/" : if result.count >= 2 {
            op2 = result.removeLast()
            if op2 == 0 {
                error("Division by zero")
            }
            op1 = result.removeLast()
            result += [op1 / op2]
        } else {
            error(nil)
            }
        case "+" : if result.count >= 2 {
            result += [result.removeLast() + result.removeLast()]
        } else {
            error(nil)
            }
        case "-" : if result.count >= 2 {
            op2 = result.removeLast()
            op1 = result.removeLast()
            result += [op1 - op2]
        } else {
            error(nil)
            }
        case "s" : if result.count >= 1 {
            result += [sin(result.removeLast())]
        } else {
            error(nil)
            }
        case "c" : if result.count >= 1 {
            result += [cos(result.removeLast())]
        } else {
            error(nil)
            }
        case "x" : if result.count >= 1 {
            result += [exp(result.removeLast())]
        } else {
            error(nil)
            }
        case "^" : if result.count >= 2 {
            op2 = result.removeLast()
            op1 = result.removeLast()
            result += [pow(op1, op2)]
        } else {
            error(nil)
            }
        case "(",")" : error("Unclosed brackets")
        default : if element != " " {
            stackOper.append(element)
            continue
        }
        if !stackOper.isEmpty && isNumber(stackOper) {
            result += [stringToDouble(stackOper)] // помещаем в стек только числа
            stackOper.removeAll(keepCapacity: true)
            }
        }
    }
    if result.isEmpty && ![stackOper].isEmpty {
        result += [stringToDouble(stackOper)]
    } else if result.isEmpty && [stackOper].isEmpty {
        result += [0.0]
        error(nil)
    }
    return result.last!
}

func error(errorString:String?) {
    
    if (errorString == nil) {
        println("Expression error")
    } else {
        println("Expression error" + " : " + errorString!)
    }
    exit(0)
}

func input() {
    var count = 0;
    var inputString = String()
    for arg in Process.arguments {
        inputString = arg
        count++
    }
    if count <= 1 {
        println("Please try again in command line and input arguments in quotes")
    } else if count > 1 {
        println(String(format : "%.5f", calculate(inputString)))
    }
}

input()