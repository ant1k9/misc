curl 'https://api.investmoscow.ru/investmoscow/tender/v2/filtered-tenders/searchtenderobjects' \
  -H 'accept: application/json' \
  -H 'content-type: application/json' \
  --data-raw '{"tenderStatus":"nsi:tender_status_tender_filter:1","orderBy":"CreateDate","orderAsc":false,"pageNumber":1,"pageSize":100,"subCategory":1}' \
  | jq '.entities | map(.tenders | flatten) | flatten | map({ "href": ( "https://investmoscow.ru" + .url ) , "title": ( .objectAddress + ", м." + .subwayStations[0].subwayStationName + ", " + ( .objectArea | tostring ) + " кв.м., " + ( .startPrice | tostring ) + " руб." ) })' > "$LINKS_FILE"
