import QtQuick 2.0
import Sailfish.Silica 1.0

ListModel {
    id: egwModel

    Component.onCompleted: {
        var week = 64800000*7;
        var values = {date: new Date(), e:900, g:300, w:50.00, sectionProperty:''};
        for (var i=30; i>0; i--) {
            values.date = new Date( 1514764800000 + (week*i) );
            values.e = values.e + i;
            values.g = values.g + (i*7);
            values.w = Math.round( (values.w + (i*0.2)) * 100) / 100;

            values.sectionProperty = values.date.toLocaleString(Qt.locale(), egwList.sectionFormat);

            append(values);
        }
    }
}
