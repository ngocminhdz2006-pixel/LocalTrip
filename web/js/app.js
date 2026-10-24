// Confirm before deleting items (itinerary item, expense, etc.)
function confirmDelete(message) {
    return confirm(message || "Are you sure you want to delete this item?");
}

// Floating Toast Notification System replacing browser alert()
function showLocalTripToast(message, type) {
    var container = document.getElementById("localTripToastContainer");
    if (!container) {
        container = document.createElement("div");
        container.id = "localTripToastContainer";
        container.style.position = "fixed";
        container.style.bottom = "24px";
        container.style.right = "24px";
        container.style.zIndex = "99999";
        container.style.display = "flex";
        container.style.flexDirection = "column";
        container.style.gap = "10px";
        container.style.pointerEvents = "none";
        document.body.appendChild(container);
    }

    var toast = document.createElement("div");
    toast.className = "localtrip-toast";
    toast.style.pointerEvents = "auto";
    toast.style.minWidth = "260px";
    toast.style.maxWidth = "380px";
    toast.style.padding = "12px 18px";
    toast.style.borderRadius = "12px";
    toast.style.fontSize = "13.5px";
    toast.style.fontWeight = "600";
    toast.style.boxShadow = "0 8px 24px rgba(0,0,0,0.18)";
    toast.style.display = "flex";
    toast.style.alignItems = "center";
    toast.style.gap = "10px";
    toast.style.transition = "all 0.3s cubic-bezier(0.16, 1, 0.3, 1)";
    toast.style.opacity = "0";
    toast.style.transform = "translateY(20px)";

    var icon = "ℹ️";
    if (type === "success") {
        toast.style.background = "#175b43";
        toast.style.color = "#ffffff";
        icon = "✓";
    } else if (type === "error" || type === "danger") {
        toast.style.background = "#b91c1c";
        toast.style.color = "#ffffff";
        icon = "⚠️";
    } else if (type === "warning") {
        toast.style.background = "#d97706";
        toast.style.color = "#ffffff";
        icon = "⚠️";
    } else {
        toast.style.background = "#1e293b";
        toast.style.color = "#ffffff";
        icon = "🔔";
    }

    toast.innerHTML = '<span style="font-size: 16px;">' + icon + '</span><span>' + message + '</span>';
    container.appendChild(toast);

    // Animate in
    setTimeout(function () {
        toast.style.opacity = "1";
        toast.style.transform = "translateY(0)";
    }, 10);

    // Auto dismiss after 3.5 seconds
    setTimeout(function () {
        toast.style.opacity = "0";
        toast.style.transform = "translateY(20px)";
        setTimeout(function () {
            if (toast.parentNode) {
                toast.parentNode.removeChild(toast);
            }
        }, 350);
    }, 3500);
}

// UI setup on DOMContentLoaded
document.addEventListener("DOMContentLoaded", function () {
    // Highlight active navigation links
    document.querySelectorAll(".app-nav-links a, .trip-workspace a").forEach(function (link) {
        var url = new URL(link.href, location.href);

        var current = location.pathname;
        var target = url.pathname;
        var mainLink = link.closest(".app-nav-links");
        var active = target === current;
        if (mainLink) {
            var brandEl = document.querySelector(".app-brand");
            var base = brandEl ? brandEl.pathname.replace(/\/(?:user|admin|login)$/, "") : "";
            var route = current.slice(base.length);
            var navRoute = target.slice(base.length);
            if (navRoute === "/trips") active = /^\/(?:trips|trip(?:\/|$)|preferences(?:\/|$)|recommendations|combo|itinerary(?:\/|$)|expenses(?:\/|$)|settlement|group-fund)/.test(route);
            if (navRoute === "/places") active = /^\/places(?:\/|$)/.test(route);
            if (navRoute === "/dump") active = /^\/(?:dump|checkin)(?:\/|$)/.test(route);
            if (navRoute.startsWith("/admin/")) active = route === navRoute || route.startsWith(navRoute + "/");
        }
        if (active) {
            link.classList.add("active");
            link.setAttribute("aria-current", "page");
        }
    });

    // Responsive table keyboard scrolling
    document.querySelectorAll("main table").forEach(function (table) {
        var wrapper = table.closest(".table-responsive");

        if (!wrapper) {
            wrapper = document.createElement("div");
            wrapper.className = "table-responsive";
            table.parentNode.insertBefore(wrapper, table);
            wrapper.appendChild(table);
        }

        wrapper.tabIndex = 0;
        wrapper.setAttribute("role", "region");
        wrapper.setAttribute(
                "aria-label",
                "Data table — scroll horizontally to view more"
                );
    });

    // Update selected category count
    var checkboxes = document.querySelectorAll(".preference-checkbox");
    var counter = document.getElementById("selectedCount");

    if (checkboxes.length && counter) {
        var updateCount = function () {
            var checked = document.querySelectorAll(
                    ".preference-checkbox:checked"
                    ).length;

            counter.textContent = checked;
        };

        checkboxes.forEach(function (checkbox) {
            checkbox.addEventListener("change", updateCount);
        });

        updateCount();
    }

    // Select/Deselect all participants in expense form
    var selectAll = document.getElementById("selectAllParticipants");

    if (selectAll) {
        selectAll.addEventListener("change", function () {
            document.querySelectorAll(".participant-checkbox").forEach(function (checkbox) {
                checkbox.checked = selectAll.checked;
            });
        });
    }

    // When paying from group fund, default payer to Trip Owner
    var fromFund = document.getElementById("fromFund");
    var payerSelect = document.getElementById("payerId");

    if (fromFund && payerSelect) {
        fromFund.addEventListener("change", function () {
            if (!fromFund.checked) {
                return;
            }

            var ownerOption = payerSelect.querySelector(
                    'option[data-owner="true"]'
                    );

            if (ownerOption) {
                payerSelect.value = ownerOption.value;
            }
        });
    }
});

(function(){
    document.querySelectorAll('.trip-workspace nav a').forEach(function(link){
        if(new URL(link.href).pathname === window.location.pathname){
            link.classList.add('active');
            link.setAttribute('aria-current','page');
        }
    });
})();

// Reload server data when returning to an itinerary restored from browser history
window.addEventListener('pageshow', function(event) {
    if (event.persisted && document.getElementById('itineraryMapData')) window.location.reload();
});
