package com.yido.road.sos.controller.api;

import java.util.HashMap;
import java.util.Map;

import com.yido.road.sos.model.StaCalcReq;
import com.yido.road.sos.model.StaCalcResult;

import com.yido.road.sos.service.api.StaService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

/**
 * 좌표 기반 STA 계산 API
 */
@RestController
@RequiredArgsConstructor
@RequestMapping("/api/sta")
public class StaApiController {

    private final StaService staService;

    @PostMapping("/calc")
    public ResponseEntity<?> calc(@RequestBody StaCalcReq req) {

        StaCalcResult r = staService.calcSta(req.getSiteCd(), req.getDirectionCd(), req.getLat(), req.getLng());

        if (r == null) {
            Map<String, Object> out = new HashMap<String, Object>();
            out.put("ok", false);
            out.put("msg", "STA not found (line_json parse fail or too far)");
            return ResponseEntity.ok(out);
        }

        Map<String, Object> out = new HashMap<String, Object>();
        out.put("ok", true);
        out.put("data", r);
        return ResponseEntity.ok(out);
    }


    @PostMapping("/match")
    public ResponseEntity<?> match(@RequestBody StaCalcReq req) {

        Map<String, Object> m = staService.matchBestSite(
                req.getSiteCd(),
                req.getDirectionCd(),
                req.getLat(),
                req.getLng()
        );

        if (m == null) {
            Map<String, Object> out = new HashMap<String, Object>();
            out.put("ok", false);
            out.put("msg", "no candidates");
            return ResponseEntity.ok(out);
        }

        Map<String, Object> out = new HashMap<String, Object>();
        out.put("ok", true);
        out.put("data", m);
        return ResponseEntity.ok(out);
    }


    /* 하위노선 존재여부 */
    @PostMapping("/has-sub")
    public ResponseEntity<?> hasSub(@RequestBody StaCalcReq req) {

        boolean hasSub = staService.hasSubRoutes(req.getSiteCd());

        Map<String, Object> out = new HashMap<String, Object>();
        out.put("ok", true);
        out.put("data", hasSub);
        return ResponseEntity.ok(out);
    }


    @GetMapping("/reverseLineJson")
    public Map<String, Object> reverseLineJson(
            @RequestParam("siteCd") String siteCd,
            @RequestParam("directionCd") String directionCd,
            @RequestParam("segNo") int segNo
    ) {
        int updated = staService.reverseAndSaveLineJson(siteCd, directionCd, segNo);

        Map<String, Object> res = new HashMap<>();
        res.put("success", updated > 0);
        res.put("updated", updated);
        return res;
    }
}