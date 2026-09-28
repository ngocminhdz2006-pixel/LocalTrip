// Xac nhan truoc khi xoa (itinerary item, expense...)
function confirmDelete(message) {
    return confirm(message || "Bạn có chắc muốn xóa mục này?");
}

// Cap nhat so luong category da chon trong preference-form.jsp
document.addEventListener("DOMContentLoaded", function () {
    var checkboxes = document.querySelectorAll(".preference-checkbox");
    var counter = document.getElementById("selectedCount");
    if (checkboxes.length && counter) {
        var updateCount = function () {
            var checked = document.querySelectorAll(".preference-checkbox:checked").length;
            counter.textContent = checked;
        };
        checkboxes.forEach(function (cb) {
            cb.addEventListener("change", updateCount);
        });
        updateCount();
    }

    // Toggle chon tat ca participants trong expense-form.jsp
    var selectAll = document.getElementById("selectAllParticipants");
    if (selectAll) {
        selectAll.addEventListener("change", function () {
            document.querySelectorAll(".participant-checkbox").forEach(function (cb) {
                cb.checked = selectAll.checked;
            });
        });
    }
});
