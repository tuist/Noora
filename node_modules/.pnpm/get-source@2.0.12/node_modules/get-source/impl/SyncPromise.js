"use strict";

/*  ------------------------------------------------------------------------ */

module.exports = class SyncPromise {

    constructor (fn) {
        try {
            fn (
                x => { this.setValue (x, false) }, // resolve
                x => { this.setValue (x, true) }   // reject
            )
        } catch (e) {
            this.setValue (e, true)
        }
    }

    setValue (x, rejected) {
        this.val      = (x instanceof SyncPromise) ? x.val : x
        this.rejected = rejected || ((x instanceof SyncPromise) ? x.rejected : false)
    }

    static valueFrom (x) {
        if (x instanceof SyncPromise) {
            if (x.rejected) throw  x.val
            else            return x.val
        } else {
            return x
        }
    }

    then (fn) {
        try       { if (!this.rejected) return SyncPromise.resolve (fn (this.val)) }
        catch (e) {                     return SyncPromise.reject (e) }
        return this
    }

    catch (fn) {
        try       { if (this.rejected) return SyncPromise.resolve (fn (this.val)) }
        catch (e) {                    return SyncPromise.reject (e) }
        return this
    }

    static resolve (x) {
        return new SyncPromise (resolve => { resolve (x) })
    }

    static reject (x) {
        return new SyncPromise ((_, reject) => { reject (x) })
    }
}