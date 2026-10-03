trigger PreventDoubleBooking on Event__c (before insert, before update) {
    Set<Id> venueIds = new Set<Id>();
    Set<Date> eventDates = new Set<Date>();

    for(Event__c ev : Trigger.new){
        if(ev.Venue__c != null && ev.Event_Date__c != null){
            venueIds.add(ev.Venue__c);
            eventDates.add(ev.Event_Date__c);
        }
    }

    if(venueIds.isEmpty()) return;

    // Already saved events (same venue + same date)
    Map<String, Id> existing = new Map<String, Id>();
    for(Event__c e : [SELECT Id, Venue__c, Event_Date__c
                      FROM Event__c
                      WHERE Venue__c IN :venueIds
                      AND Event_Date__c IN :eventDates]){
        existing.put(e.Venue__c + '_' + String.valueOf(e.Event_Date__c), e.Id);
    }

    // Same batch kulla duplicate irundha pidikka
    Set<String> seenInBatch = new Set<String>();

    for(Event__c ev : Trigger.new){
        if(ev.Venue__c == null || ev.Event_Date__c == null) continue;

        String key = ev.Venue__c + '_' + String.valueOf(ev.Event_Date__c);

        if((existing.containsKey(key) && existing.get(key) != ev.Id) || seenInBatch.contains(key)){
            ev.addError('This Venue is already booked on this date.');
        } else {
            seenInBatch.add(key);
        }
    }
}
