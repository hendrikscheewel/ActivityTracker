import QtQuick 2.4
import QtPositioning 5.9
import Ubuntu.Components 1.3
import QtQuick.Layouts 1.1
import io.thp.pyotherside 1.5
import QtSystemInfo 5.0
import QtLocation 5.9
import Ubuntu.Components.ListItems 1.3 as ListItem
import Ubuntu.Components.Popups 1.3
import Morph.Web 0.1



Page {
   header: PageHeader {
      id: map_header
      title: i18n.tr("Activity Map")
      trailingActionBar.actions: [
         Action {
            text: i18n.tr("Info")
            iconName: "info"
            onTriggered: {
                 indexrun = index
                 infodis=""
                 PopupUtils.open(infogpx)
                 pygpx.info_run(index)
            }
         }
      ]
   }
   id: mainPage
   property var polyline
   property var index

   ActivityIndicator {
       id:refreshmap
       anchors.centerIn: parent
       z: 5
   }

   Python {
      id: pygpxmap
      Component.onCompleted: {

         addImportPath(Qt.resolvedUrl('py/'));
         importModule("geepeeex", function() {
            console.warn("calling python script to load the gpx file")
            refreshmap.visible = true
            refreshmap.running = true
            refreshmap.focus = true
            pygpxmap.call("geepeeex.visu_gpx", [polyline], function(result) {
               var t = new Array (0)
               var lonmin = result[0].longitude
               var lonmax = result[0].longitude
               var latmin = result[0].latitude
               var latmax = result[0].latitude
               for (var i=0; i<result.length; i++) {
                  pline.addCoordinate(QtPositioning.coordinate(result[i].latitude,result[i].longitude));
                  lonmin = Math.min(lonmin,result[i].longitude)
                  lonmax = Math.max(lonmax,result[i].longitude)
                  latmin = Math.min(latmin,result[i].latitude)
                  latmax = Math.max(latmax,result[i].latitude)
               }
               map.visibleRegion = QtPositioning.rectangle(QtPositioning.coordinate(latmin, lonmin), QtPositioning.coordinate(latmax, lonmax));
               map.center = QtPositioning.coordinate(latmin+(latmax-latmin)/2,lonmin+(lonmax-lonmin)/2);
               map.zoomLevel = map.zoomLevel*0.95
               refreshmap.visible = false
               refreshmap.running = false
               refreshmap.focus = false
            });
         });
      }//Component.onCompleted
   }
   Plugin {
      id: mapPlugin
      name: "osm"
   }
   Map {
      id: map
      anchors.fill: parent
      center: QtPositioning.coordinate(29.62289936, -95.64410114) // Oslo
      zoomLevel: map.maximumZoomLevel - 5
      color: Theme.palette.normal.background
      plugin : Plugin {
         id: plugin
         allowExperimental: true
         preferred: ["osm"]
         required.mapping: Plugin.AnyMappingFeatures
         required.geocoding: Plugin.AnyGeocodingFeatures
      }

      MapPolyline {
         id: pline
         line.width: 4
         line.color: 'red'
         path: []
      }
   }

}
