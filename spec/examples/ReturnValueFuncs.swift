class ReturnValueFuncs {

    func myFunc(arg1: String) -> String {
        return "Foo"
    }

    func myFuncOptionalReturn(arg1: String) -> String? {
        return nil
    }

    func myFuncReturningTuple() -> (val1: String, val2: String) {
        return ("Foo", "Bar")
    }

}
