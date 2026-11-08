/**
 * DFM KORBA OFFICIAL APP - DATABASE SERVICE
 * Enterprise Google Sheets Data Access Layer
 * Supports 32 normalized tables with concurrency locks, UUID generation and caching.
 */

var DatabaseService = (function() {
  
  /**
   * Get Spreadsheet instance.
   */
  function getSpreadsheet() {
    var props = PropertiesService.getScriptProperties();
    var sheetId = props.getProperty('SPREADSHEET_ID');
    if (sheetId) {
      return SpreadsheetApp.openById(sheetId);
    }
    return SpreadsheetApp.getActiveSpreadsheet();
  }

  /**
   * Get or create a sheet tab by name.
   */
  function getSheet(sheetName) {
    var ss = getSpreadsheet();
    var sheet = ss.getSheetByName(sheetName);
    if (!sheet) {
      sheet = ss.insertSheet(sheetName);
    }
    return sheet;
  }

  /**
   * Read all rows from a sheet as an array of JSON objects based on the header row.
   */
  function getAllRows(sheetName) {
    var sheet = getSheet(sheetName);
    var data = sheet.getDataRange().getValues();
    if (data.length <= 1) return [];

    var headers = data[0];
    var rows = [];

    for (var i = 1; i < data.length; i++) {
      var rowObj = {};
      var isEmpty = true;
      for (var j = 0; j < headers.length; j++) {
        var headerKey = headers[j].toString().trim();
        var cellVal = data[i][j];
        if (cellVal instanceof Date) {
          cellVal = cellVal.toISOString();
        }
        rowObj[headerKey] = cellVal;
        if (cellVal !== '' && cellVal !== null && cellVal !== undefined) {
          isEmpty = false;
        }
      }
      if (!isEmpty) {
        rows.push(rowObj);
      }
    }
    return rows;
  }

  /**
   * Find rows matching a filter predicate function.
   */
  function findRows(sheetName, predicate) {
    var rows = getAllRows(sheetName);
    return rows.filter(predicate);
  }

  /**
   * Find a single row matching key/value.
   */
  function findRowByKey(sheetName, keyName, keyValue) {
    var rows = getAllRows(sheetName);
    for (var i = 0; i < rows.length; i++) {
      if (String(rows[i][keyName]) === String(keyValue)) {
        return rows[i];
      }
    }
    return null;
  }

  /**
   * Atomic row insertion with LockService.
   */
  function insertRow(sheetName, rowData) {
    var lock = LockService.getScriptLock();
    try {
      lock.waitLock(15000); // 15s lock wait

      var sheet = getSheet(sheetName);
      var data = sheet.getDataRange().getValues();
      if (data.length === 0) {
        throw new Error("Sheet '" + sheetName + "' has no headers defined.");
      }

      var headers = data[0];
      var newRow = [];

      // Auto-set timestamps if columns exist
      var nowIso = new Date().toISOString();
      if (rowData.created_at === undefined) rowData.created_at = nowIso;
      if (rowData.updated_at === undefined) rowData.updated_at = nowIso;
      if (rowData.status === undefined) rowData.status = 'ACTIVE';

      for (var j = 0; j < headers.length; j++) {
        var headerKey = headers[j].toString().trim();
        var val = rowData[headerKey];
        if (val === undefined || val === null) {
          newRow.push('');
        } else if (typeof val === 'object') {
          newRow.push(JSON.stringify(val));
        } else {
          newRow.push(val);
        }
      }

      sheet.appendRow(newRow);
      SpreadsheetApp.flush();
      return rowData;
    } finally {
      lock.releaseLock();
    }
  }

  /**
   * Batch insert multiple rows atomically.
   */
  function insertRowsBatch(sheetName, rowsArray) {
    if (!rowsArray || rowsArray.length === 0) return [];
    var lock = LockService.getScriptLock();
    try {
      lock.waitLock(20000);

      var sheet = getSheet(sheetName);
      var data = sheet.getDataRange().getValues();
      var headers = data[0];
      var newRows = [];
      var nowIso = new Date().toISOString();

      for (var r = 0; r < rowsArray.length; r++) {
        var rowData = rowsArray[r];
        if (rowData.created_at === undefined) rowData.created_at = nowIso;
        if (rowData.updated_at === undefined) rowData.updated_at = nowIso;
        if (rowData.status === undefined) rowData.status = 'ACTIVE';

        var newRow = [];
        for (var j = 0; j < headers.length; j++) {
          var headerKey = headers[j].toString().trim();
          var val = rowData[headerKey];
          if (val === undefined || val === null) {
            newRow.push('');
          } else if (typeof val === 'object') {
            newRow.push(JSON.stringify(val));
          } else {
            newRow.push(val);
          }
        }
        newRows.push(newRow);
      }

      var startRow = sheet.getLastRow() + 1;
      sheet.getRange(startRow, 1, newRows.length, headers.length).setValues(newRows);
      SpreadsheetApp.flush();
      return rowsArray;
    } finally {
      lock.releaseLock();
    }
  }

  /**
   * Update a row matching key/value.
   */
  function updateRow(sheetName, keyName, keyValue, updateData) {
    var lock = LockService.getScriptLock();
    try {
      lock.waitLock(15000);

      var sheet = getSheet(sheetName);
      var data = sheet.getDataRange().getValues();
      if (data.length <= 1) return false;

      var headers = data[0];
      var keyIndex = headers.indexOf(keyName);
      if (keyIndex === -1) {
        throw new Error("Key column '" + keyName + "' not found in sheet '" + sheetName + "'.");
      }

      var targetRowIndex = -1;
      for (var i = 1; i < data.length; i++) {
        if (String(data[i][keyIndex]) === String(keyValue)) {
          targetRowIndex = i + 1; // 1-based row index in sheet
          break;
        }
      }

      if (targetRowIndex === -1) {
        return false;
      }

      updateData.updated_at = new Date().toISOString();

      for (var col = 0; col < headers.length; col++) {
        var headerKey = headers[col].toString().trim();
        if (updateData.hasOwnProperty(headerKey)) {
          var val = updateData[headerKey];
          if (val === undefined || val === null) {
            val = '';
          } else if (typeof val === 'object') {
            val = JSON.stringify(val);
          }
          sheet.getRange(targetRowIndex, col + 1).setValue(val);
        }
      }

      SpreadsheetApp.flush();
      return true;
    } finally {
      lock.releaseLock();
    }
  }

  /**
   * Generate clean unique IDs with prefix.
   */
  function generateId(prefix) {
    var raw = Utilities.getUuid().replace(/-/g, '').substring(0, 10);
    return (prefix || 'REC') + '_' + raw.toUpperCase();
  }

  return {
    getSpreadsheet: getSpreadsheet,
    getSheet: getSheet,
    getAllRows: getAllRows,
    findRows: findRows,
    findRowByKey: findRowByKey,
    insertRow: insertRow,
    insertRowsBatch: insertRowsBatch,
    updateRow: updateRow,
    generateId: generateId
  };
})();
