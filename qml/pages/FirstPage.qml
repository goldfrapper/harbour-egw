import QtQuick 2.0
import Sailfish.Silica 1.0
import "../components"

Page {
    id: page
    allowedOrientations: Orientation.All

    SilicaListView {
        id: egwList
        anchors.fill: parent

        x: Theme.horizontalPageMargin
        width: parent.width - Theme.horizontalPageMargin

        property int parentWidth: parent.width - (Theme.horizontalPageMargin*2)
        property int sizeSmall: egwList.parentWidth / 5
        property int sizeLarge: (egwList.parentWidth / 5)*2

        property string sectionFormat: 'MMM yyyy'
        property string dateFormat: 'ddd d'

        PullDownMenu {
            MenuItem {
                text: qsTr("About")
                onClicked: pageStack.push(Qt.resolvedUrl("SecondPage.qml"))
            }
            MenuItem {
                text: qsTr("Settings")
                onClicked: pageStack.push(Qt.resolvedUrl("SettingsPage.qml"))
            }
            MenuItem {
                text: qsTr("Add entry")
                onClicked: pageStack.push(addValuesDialog)
            }
        }

        // Header
        header: PageHeader {
            title: qsTr("EGW monitor")
        }
//        headerPositioning: ListView.OverlayHeader

        // Start sectionHeader
        Component {
            id: sectionHeading

            Column {
                x: Theme.horizontalPageMargin
                height: Theme.itemSizeExtraSmall
                width: parent.width

                Label {
                    text: section
                    font.bold: true
                    font.pixelSize: Theme.fontSizeMedium
                    color: Theme.highlightColor
                }

                Row {
                    x: Theme.horizontalPageMargin

                    Repeater {
                        model: ['Date','Elec','Gas','Water']
                        Label {
                            text: modelData
                            width: (index == 0) ? egwList.sizeLarge : egwList.sizeSmall;
                            font.pixelSize: Theme.fontSizeExtraSmall
                        }
                    }
                }
            }
        }
        section.property: "sectionProperty"
        section.criteria: ViewSection.FullString
        section.delegate: sectionHeading
        // End SectionHeader

        model: EGW_Model { id: egwModel }

        delegate: ListItem {
            id: valuesDelegate

            width: parent.width
            contentHeight: Theme.itemSizeExtraSmall

            property int parentWidth: parent.width - (Theme.horizontalPageMargin*2)
            property int sizeSmall: valuesDelegate.parentWidth / 5
            property int sizeLarge: (valuesDelegate.parentWidth / 5)*2

            Row {
                spacing: 10

                x: Theme.horizontalPageMargin
                width: valuesDelegate.parentWidth
                anchors.verticalCenter: parent.verticalCenter

                Repeater {
                    model: [Qt.formatDate(date, egwList.dateFormat), e, g, Number(w).toLocaleString(Qt.locale(),'f',2)]
                    Label {
                        text: modelData
                        width: (index == 0)? valuesDelegate.sizeLarge : valuesDelegate.sizeSmall
                        color: valuesDelegate.highlighted ? Theme.highlightColor : Theme.primaryColor
                    }
                }
            }

            menu: ContextMenu {
                 MenuItem {
                     text: "Edit"
                     height: Theme.itemSizeExtraSmall

                     // Push the add dialog, with the current items values
                     // (the names correspond to the dialogs properties)
                     onClicked: pageStack.push( addValuesDialog, egwModel.get(model.index))
                 }
                 MenuItem {
                    text: "Remove"
                    height: Theme.itemSizeExtraSmall
                    onClicked: {

                        function removeItem() {
                            egwModel.remove(index)
                        }

                        Remorse.itemAction(valuesDelegate, "Removing", removeItem )
                    }
                 }
             }
        }




        // Start addValuesDialog
        Component {
             id: addValuesDialog

             Dialog {
                id: egwDialog

                property variant date: new Date()
                property int e: 300
                property int g: 900
                property real w: 50.00

                onAccepted: {

                    // Update all values
                    var i = egw_inputs.count;
                    while(i--) {
                        egwDialog[egw_inputs.model[i]] = egw_inputs.itemAt(i).text;
                    }
                    egwDialog.date = egw_date.date;

                    //
                    // TODO: Store data in model (add/update)
                    //
                 }

                 Column {
                     width: parent.width


                    DialogHeader {
                        id: header
                        title: "Add EGW values"
                    }

                     Row {
                        width: parent.width

                        Repeater {
                            id: egw_inputs
                            model: ['e','g','w']

                            //
                            // TODO: Create Validators the verify the given values are not higher/lower
                            // then those previously/next set in time
                            //
                            property variant intVal: IntValidator { bottom: 1 }
                            property variant doubleVal: DoubleValidator { bottom: 1; decimals: 2 }
                            property string icon: 'image://theme/icon-m-enter-'

                            TextField {
                                property bool isW: (modelData == 'w')? true : false

                                placeholderText: modelData.toUpperCase() + "-value"
                                text: egwDialog[modelData]

                                width: parent.width / 3
                                label: placeholderText
                                validator: (isW)? egw_inputs.doubleVal : egw_inputs.intVal
                                inputMethodHints: Qt.ImhFormattedNumbersOnly

                                EnterKey.enabled: text.length > 0
                                EnterKey.iconSource: egw_inputs.icon + ((isW)? 'close' : 'next')

                                EnterKey.onClicked: egw_inputs.itemAt((isW)? index : index + 1).focus = !(isW)
                            }
                        }
                     }

                     DatePicker {
                         id: egw_date
                         x: Theme.horizontalPageMargin
                         width: parent.width - Theme.horizontalPageMargin

                         date: egwDialog.date
                         daysVisible: true
                         weeksVisible: true
                         monthYearVisible: true
                     }
                 }
             }
         }
        // End addValuesDialog
    }
}
