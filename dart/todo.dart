#import('dart:dom', prefix:'dom');
#import('dart:html');

String VERSION = "1";
String TODOS_STORE = 'todos';

initDb(db) {
  if (VERSION != db.version) {
    dom.IDBVersionChangeRequest versionChange = db.setVersion(VERSION);
    versionChange.addEventListener('success', (e) {
      print("Set version");
      db.createObjectStore(TODOS_STORE);
      displayItems(db);
    });
    versionChange.addEventListener('error', (e) {
      print("Could not set version: $e");
    });
  } else {
    print("DB is at version ${db.version}");
    displayItems(db);
  }
}

displayItems(dom.IDBDatabase db) {
  dom.IDBTransaction txn = db.transaction(TODOS_STORE, dom.IDBTransaction.READ_ONLY);
  dom.IDBObjectStore objectStore = txn.objectStore(TODOS_STORE);
  dom.IDBRequest cursorRequest = objectStore.openCursor();
  cursorRequest.addEventListener("success", (e) {
    dom.IDBCursor cursor = e.target.result;
    if (cursor != null) {
      renderItem(cursor.value);
      cursor.continueFunction();
    }
  });
  cursorRequest.addEventListener('error', (e) {
    print("Could not open cursor: $e");
  });
}

renderItem(value) {
  var ul = document.query('#items');
  var li = new Element.tag("li");
  li.text = value;
  ul.elements.add(li);
}

addItem(db) {
  var msg = "Stuff ${new Date.now().value}";
  dom.IDBTransaction txn = db.transaction(TODOS_STORE, dom.IDBTransaction.READ_WRITE);
  dom.IDBObjectStore objectStore = txn.objectStore(TODOS_STORE);
  dom.IDBRequest addRequest = objectStore.put(msg, new Date.now().value);
  addRequest.addEventListener("success", (e) {
    renderItem(msg);
  });
  addRequest.addEventListener("error", (e) => print("Could not add: $e"));
}

registerButtons(db) {
  var add = document.query("#add");
  add.on.click.add((e) {
    addItem(db);
  });
}

// Chrome only for now,
// see bug http://code.google.com/p/chromium/issues/detail?id=108223
void main() {
  dom.IDBRequest request = dom.window.webkitIndexedDB.open('todo');
  request.addEventListener('success', (e) {
    print("Opened DB");
    dom.IDBDatabase db = e.target.result;
    // the following is Chrome only for now :(
    initDb(db);
    registerButtons(db);
  });
  request.addEventListener('error', (e) {
    print('Could not open db: $e');
  });
}
