/**
 * from https://raw.githubusercontent.com/nfriedly/Javascript-Flash-Cookies/master/src/Storage.as
 *
 * SwfStore - a JavaScript library for cross-domain flash cookies
 *
 * http://github.com/nfriedly/Javascript-Flash-Cookies
 *
 * Copyright (c) 2010 by Nathan Friedly - Http://nfriedly.com
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

package {

import flash.display.Sprite;
import flash.display.Stage;
import flash.events.*;
import flash.external.ExternalInterface;
import flash.text.TextField;
import flash.system.Security;
import flash.net.SharedObject;
import flash.net.SharedObjectFlushStatus;

public class Storage extends Sprite {

    /**
     * The JS callback functions should all be on a global variable at SwfStore.<namespace>.<function name>
     */
    private var jsNamespace:String = "SwfStore.swfstore.";

    /**
     * Namespace portion provided by JS is tested against this to avoid XSS
     */
    private var namespaceCheck:RegExp = /^[a-z0-9_\/]+$/i;

    /**
     * Text field used by local logging
     */
    private var logText:TextField;

    /**
     * Constructor, sets up everything and logs any errors.
     * Call this automatically by setting Publish > Class tp "Storage" in your .fla properties.
     *
     *
     *
     * If javascript is unable to access this object and not recieving any log messages (at wh
     */
    public function Storage() {
        // Make sure we can talk to javascript at all
        if (!ExternalInterface.available) {
            localLog("External Interface is not available! (No communication with JavaScript.) Exiting.");
            return;
        }
        ExternalInterface.marshallExceptions = true; // try to pass errors to JS and capture errors from JS

        if (this.loaderInfo.parameters.namespace && !namespaceCheck.test(this.loaderInfo.parameters.namespace)) {
            localLog("Invalid namespace, disabling");
            return;
        }

        // since even logging involves communicating with javascript,
        // the next thing to do is find the external log function
        if (this.loaderInfo.parameters.namespace) {
            jsNamespace = "SwfStore." + this.loaderInfo.parameters.namespace.replace("/", "_") + ".";
        }

        log('Initializing...');

        // This is necessary to work cross-domain
        // Ideally you should add only the domains that you need, for example
        //   Security.allowDomain("nfriedly.com", "www.nfriedly.com");
        // and then comment the allowInsecureDomain line.
        // More information: http://help.adobe.com/en_US/FlashPlatform/reference/actionscript/3/flash/system/Security.html#allowDomain%28%29
        Security.allowDomain("swarmsim.github.io", "swarmsim-staging.github.io", "swarmsim-publictest.github.io", "www.swarmsim.com", "swarmsim.com", "staging.swarmsim.com", "publictest.swarmsim.com");
        Security.allowInsecureDomain("swarmsim.github.io", "swarmsim-staging.github.io", "swarmsim-publictest.github.io", "www.swarmsim.com", "swarmsim.com", "staging.swarmsim.com", "publictest.swarmsim.com");

        // try to initialize our lso
        try {
            var dataStore:SharedObject = SharedObject.getLocal(this.loaderInfo.parameters.namespace);
        } catch (error:Error) {
            // user probably unchecked their "allow third party data" in their global flash settings
            log('Unable to create a local shared object. Exiting - ' + error.message);
            onError();
            return;
        }

        try {
            // expose our external interface
            ExternalInterface.addCallback("set", setValue);
            ExternalInterface.addCallback("get", getValue);
            ExternalInterface.addCallback("getAll", getAllValues);
            ExternalInterface.addCallback("clear", clearValue);

            // There is a bug in flash player where if no values have been saved and the page is
            // then refreshed, the flashcookie gets deleted - even if another tab *had* saved a
            // value to the flashcookie.
            // So to fix, we immediately save something
            this.setValue('__flashBugFix', '1');

            log('Ready! Firing onload...');

            ExternalInterface.call(jsNamespace + "onload");

        } catch (error:SecurityError) {
            log("A SecurityError occurred: " + error.message + "\n");
            onError();
        } catch (error:Error) {
            log("An Error occurred: " + error.message + "\n");
            onError();
        }
    }

    /**
     * Attempts to notify JS when there was an error during initialization
     */
    private function onError():void {
        try {
            if (ExternalInterface.available) {
                ExternalInterface.call(jsNamespace + "onerror");
            }
        } catch (error:Error) {
            log('Error attempting to fire JS onerror callback - ' + error.message);
        }
    }

    /**
     * Saves the data to the LSO, and then flushes it to the disk
     *
     * @param {string} key
     * @param {string} value - Expects a string. Objects will be converted to strings, functions tend to cause problems.
     */
    private function setValue(key:String, val:*):void {
        try {
            if (typeof val != "string") {
                val = val.toString();
            }
            var dataStore:SharedObject = SharedObject.getLocal(this.loaderInfo.parameters.namespace);

            log('Setting ' + key + '=' + val);
            dataStore.data[key] = val;
            flush(dataStore);
        } catch (error:Error) {
            log('Unable to save data - ' + error.message);
        }
    }

    /**
     * Reads and returns data from the LSO
     */
    private function getValue(key:String):String {
        try {

            var dataStore:SharedObject = SharedObject.getLocal(this.loaderInfo.parameters.namespace);

            log('Reading ' + key);
            var val:String = dataStore.data[key];

            return val;
        } catch (error:Error) {
            log('Unable to read data - ' + error.message);
        }
        return null;
    }

    /**
     * Deletes an item from the LSO
     */
    private function clearValue(key:String):void {
        try {
            log("Deleting " + key);
            var dataStore:SharedObject = SharedObject.getLocal(this.loaderInfo.parameters.namespace);
            delete dataStore.data[key];
            flush(dataStore);
        } catch (error:Error) {
            log("Error deleting key - " + error.message);
        }
    }

    /**
     * This retrieves all stored data
     */
    private function getAllValues():Array {
        var dataStore:SharedObject = SharedObject.getLocal(this.loaderInfo.parameters.namespace);

        var pairs:Array = new Array();
        for (var key:String in dataStore.data) {
            if (key != "__flashBugFix") {
                // Flash has (another) bug where string keys that start with numbers are sent to JS without quotes. JS then fails to parse this because it's not valid JSON
                // https://github.com/nfriedly/Javascript-Flash-Cookies/issues/21
                var pair:Object = {
                    key: key,
                    value: dataStore.data[key]
                };
                pairs.push(pair);
            }
        }
        return pairs;
    }

    /**
     * Flushes changes to the dataStore
     */
    private function flush(dataStore:SharedObject):void {
        var flushStatus:String = null;
        try {
            flushStatus = dataStore.flush(10000);
        } catch (error:Error) {
            log("Error...Could not write SharedObject to disk - " + error.message);
        }

        if (flushStatus != null) {
            switch (flushStatus) {
                case SharedObjectFlushStatus.PENDING:
                    log("Requesting permission to save object...");
                    dataStore.addEventListener(NetStatusEvent.NET_STATUS, onFlushStatus);
                    break;
                case SharedObjectFlushStatus.FLUSHED:
                    // don't really need another message when everything works right
                    //log("Value flushed to disk.");
                    break;
            }
        }
    }

    /**
     * This happens if the user is prompted about saving locally
     */
    private function onFlushStatus(event:NetStatusEvent):void {
        log("User closed permission dialog...");
        switch (event.info.code) {
            case "SharedObject.Flush.Success":
                log("User granted permission -- value saved.");
                break;
            case "SharedObject.Flush.Failed":
                log("User denied permission -- value not saved.");
                break;
        }

        var dataStore:SharedObject = SharedObject.getLocal(this.loaderInfo.parameters.namespace);
        dataStore.removeEventListener(NetStatusEvent.NET_STATUS, onFlushStatus);
    }

    /**
     * Attempts to log messages to the supplied javascript logFn,
     * if that fails it passes them to localLog()
     */
    private function log(str:String):void {
        try {
            ExternalInterface.call(jsNamespace + "log", 'debug', 'swfStore', str);
        } catch (error:Error) {
            localLog("Error logging to js: " + error.toString() + " - Original message was: " + str);
        }
    }

    /**
     * Last-resort logging used when communication with javascript fails or isn't avaliable.
     * The messages should appear in the flash object, but they might not be pretty.
     */
    private function localLog(str:String):void {
        // We can't talk to javascript for some reason.
        // Attempt to show this to the user (normally this swf is hidden off screen, so regular users shouldn't see it)
        if (!logText) {
            // create the text field if it doesn't exist yet
            logText = new TextField();
            logText.width = 450; // I suspect there's a way to do "100%"...
            addChild(logText);
        }
        logText.appendText(str + "\n");
    }
}
}
