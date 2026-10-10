(function (root) {
    'use strict';
    function coordinate(raw, maximum) {
        if (raw == null || String(raw).trim() === '') return null;
        const value = Number(raw);
        return Number.isFinite(value) && Math.abs(value) <= maximum ? value : null;
    }
    function readPoint(element) {
        const data = element.dataset;
        return {id: Number(data.id), name: data.name || 'Địa điểm',
            lat: coordinate(data.lat, 90), lng: coordinate(data.lng, 180),
            date: data.date || '', start: data.start || '', end: data.end || ''};
    }
    function hasCoordinates(point) { return Number.isFinite(point.lat) && Number.isFinite(point.lng); }
    function pointsForDay(points, day) {
        return points.filter(function (point) { return (day === 'ALL' || point.date === day) && hasCoordinates(point); })
            .sort(function (a, b) { return (a.date + ' ' + a.start).localeCompare(b.date + ' ' + b.start); });
    }
    function hourKey(value) {
        const match = String(value).match(/^(\d{2}):(\d{2})(?::(\d{2}))?$/);
        return match && Number(match[1]) < 24 && Number(match[2]) < 60
            && (match[3] == null || Number(match[3]) < 60) ? match[1] + ':00' : null;
    }
    function dateStamp(value) {
        if (!/^\d{4}-\d{2}-\d{2}$/.test(value)) return NaN;
        const stamp = Date.parse(value + 'T00:00:00Z');
        return Number.isFinite(stamp) && new Date(stamp).toISOString().slice(0, 10) === value ? stamp : NaN;
    }
    function dateDiffDays(value, now) {
        const parts = new Intl.DateTimeFormat('en-CA', {timeZone: 'Asia/Ho_Chi_Minh', year: 'numeric', month: '2-digit', day: '2-digit'}).formatToParts(now || new Date());
        function part(type) { return parts.find(function (item) { return item.type === type; }).value; }
        return (dateStamp(value) - dateStamp(part('year') + '-' + part('month') + '-' + part('day'))) / 86400000;
    }
    function directionsUrl(points) {
        if (!points.length) return '';
        const coordinate = function (point) { return point.lat + ',' + point.lng; };
        let url = 'https://www.google.com/maps/dir/?api=1&travelmode=driving&destination=' + encodeURIComponent(coordinate(points[points.length - 1]));
        if (points.length > 1) url += '&origin=' + encodeURIComponent(coordinate(points[0]));
        if (points.length > 2) url += '&waypoints=' + encodeURIComponent(points.slice(1, -1).map(coordinate).join('|'));
        return url;
    }
    root.LocalTripSchedule = Object.freeze({readPoint: readPoint, hasCoordinates: hasCoordinates, pointsForDay: pointsForDay,
        hourKey: hourKey, dateDiffDays: dateDiffDays, directionsUrl: directionsUrl});
})(typeof window === 'undefined' ? globalThis : window);
