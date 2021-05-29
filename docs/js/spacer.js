(function () {
    var navBarId = 'header';
    var ancorClass = 'atom-anchor';

    /** @description Получить высоту блока навигации
     * @param {string} navBarId Id блока навигации
     * @param {number} Высота блока навигации
     */
    function getNavHeight(navBarId) {
        var navBar = document.getElementById(navBarId);
        if (navBar) {
            return navBar.offsetHeight;
        } else {
            return 0;
        }
    }

    /** @description Установка смещения якорям в зависимости от высоты блока навигации
     * @param {string} navBarId Id блока навигации
     * @param {string} ancorClass Имя класса элементов, которым требуется задавать смещение
     */
    function setAncorOffset(navBarId, ancorClass) {
        var offset = getNavHeight(navBarId)
        var ancorsList = document.getElementsByClassName(ancorClass);
        for (var ancor of ancorsList) {
            ancor.style.marginTop = -offset + "px";
        }
    }

    /** @description Перемещение к указанному в адресной строке якорю */
    function goToAncorFromHash() {
        if (window.location.hash) {
            window.location = window.location;
        }
    }

    window.addEventListener("load", () => {
        setAncorOffset(navBarId, ancorClass);
        goToAncorFromHash();
    });

    window.addEventListener("resize", () => {
        setAncorOffset(navBarId, ancorClass);
    });
})();