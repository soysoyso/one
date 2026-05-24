package com.yido.road.sos.component;


import lombok.extern.slf4j.Slf4j;
import lombok.var;
import org.springframework.stereotype.Component;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.CopyOnWriteArrayList;

@Component
@Slf4j
public class AlertStreamManager {

    private final Map<String, CopyOnWriteArrayList<SseEmitter>> emittersBySite = new ConcurrentHashMap<>();
    private final Map<SseEmitter, Set<String>> sitesByEmitter = new ConcurrentHashMap<>();

    public SseEmitter subscribeMulti(String siteCdListCsvOrAll, long timeoutMs) {
        SseEmitter emitter = new SseEmitter(timeoutMs);

        Set<String> sites = parseSites(siteCdListCsvOrAll); // ALL 처리 포함
        sitesByEmitter.put(emitter, sites);

        for (String siteCd : sites) {
            log.debug("------------>" + siteCd);
            emittersBySite.computeIfAbsent(siteCd, k -> new CopyOnWriteArrayList<>()).add(emitter);
        }

        emitter.onCompletion(() -> removeEmitterEverywhere(emitter));
        emitter.onTimeout(() -> removeEmitterEverywhere(emitter));
        emitter.onError((e) -> removeEmitterEverywhere(emitter));

        try {
            emitter.send(SseEmitter.event().name("connected").data("ok"));
        } catch (Exception e) {
            removeEmitterEverywhere(emitter);
        }

        return emitter;
    }

    public void sendToSite(String siteCd, String eventName, Object payload) {
        var list = emittersBySite.get(siteCd);
        if (list == null) return;

        for (SseEmitter emitter : list) {
            try {
                emitter.send(SseEmitter.event().name(eventName).data(payload));
            } catch (Exception e) {
                removeEmitterEverywhere(emitter);
            }
        }
    }

    private void removeEmitterEverywhere(SseEmitter emitter) {
        Set<String> sites = sitesByEmitter.remove(emitter);
        if (sites == null) return;

        for (String siteCd : sites) {
            var list = emittersBySite.get(siteCd);
            if (list != null) list.remove(emitter);
        }
    }

    private Set<String> parseSites(String csvOrAll) {
        Set<String> set = ConcurrentHashMap.newKeySet();

        if (csvOrAll == null || csvOrAll.trim().isEmpty() || "ALL".equalsIgnoreCase(csvOrAll.trim())) {
            set.add("ALL");
            return set;
        }

        String normalized = csvOrAll
                .replace("[", "")
                .replace("]", "");

        String[] arr = normalized.split(",");
        for (String s : arr) {
            String v = s.trim();
            if (!v.isEmpty()) set.add(v);
        }
        return set;
    }

}