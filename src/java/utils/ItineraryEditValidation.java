package utils;

import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Time;
import model.ItineraryItem;
import model.Trip;
import model.Place;

public final class ItineraryEditValidation {
    private ItineraryEditValidation() { }
    public static void validate(Trip trip, ItineraryItem original, ItineraryItem edited, Place place, Date today) {
        if (!"OWNER".equals(trip.getRole()) || !("PLANNING".equals(trip.getStatus()) || "ONGOING".equals(trip.getStatus())))
            throw new IllegalArgumentException("Chỉ trưởng nhóm được sửa lịch của chuyến đi đang lên kế hoạch hoặc đang diễn ra.");
        if (original.getVisitDate().before(today)) throw new IllegalArgumentException("Không thể sửa hoạt động của ngày đã qua.");
        if (edited.getVisitDate().before(today) || edited.getVisitDate().before(trip.getStartDate()) || edited.getVisitDate().after(trip.getEndDate()))
            throw new IllegalArgumentException("Ngày hoạt động phải nằm trong chuyến đi và không được là ngày quá khứ.");
        if (!edited.getEndTime().after(edited.getStartTime())) throw new IllegalArgumentException("Giờ kết thúc phải sau giờ bắt đầu.");
        BigDecimal cost = edited.getEstimatedCost();
        if (cost == null || cost.signum() < 0 || cost.compareTo(new BigDecimal("9999999999999999.99")) > 0 || cost.stripTrailingZeros().scale() > 2)
            throw new IllegalArgumentException("Chi phí không hợp lệ; nhập số không âm và tối đa hai chữ số thập phân.");
        if (edited.getNote() != null && edited.getNote().length() > 500) throw new IllegalArgumentException("Ghi chú không được vượt quá 500 ký tự.");
        if (place == null || !place.isActive()) throw new IllegalArgumentException("Địa điểm không còn hoạt động.");
        Time open = place.getOpeningTime(), close = place.getClosingTime();
        boolean overnight = open != null && close != null && close.before(open);
        boolean valid = overnight ? (!edited.getStartTime().before(open) || !edited.getEndTime().after(close))
                : (open == null || !edited.getStartTime().before(open)) && (close == null || !edited.getEndTime().after(close));
        if (!valid) throw new IllegalArgumentException("Giờ hoạt động phải nằm trong giờ mở cửa của địa điểm.");
    }
}
