package com.yido.road.sos.admin;

import com.yido.road.sos.component.AlertStreamManager;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.security.Principal;

@RestController
@RequiredArgsConstructor
@RequestMapping("/admin/alerts")
public class AlertController {
    private final AlertStreamManager streamManager;

    // 예: /admin/alerts/stream?siteCdList=0001,0002
    @GetMapping("/stream")
    public SseEmitter stream(@RequestParam String siteCdList, Principal principal) {
        return streamManager.subscribeMulti(siteCdList, 60L * 60 * 1000);
    }
}