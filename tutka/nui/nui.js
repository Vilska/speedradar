window.addEventListener("message", (e) => {
    switch(e.data.action) {

        case "radarOn":
            $("body").fadeIn();
            break;

        case "radarOff":
            $("body").fadeOut();
            break;

        case "targetSpeed":

            let targetSection = document.querySelector("#left");
            let firstValue = targetSection.querySelector("#first");
            let secondValue = targetSection.querySelector("#second");
            let thirdValue = targetSection.querySelector("#third");

            if (!e.data.value) {
                firstValue.innerHTML = ""
                secondValue.innerHTML = ""
                thirdValue.innerHTML = ""
                return
            }

            let targetSpeed = String(e.data.value)

            switch(targetSpeed.length) {
                case 1:
                    firstValue.innerHTML = targetSpeed[0]
                    secondValue.innerHTML = ""
                    thirdValue.innerHTML = ""
                    break;
                case 2:
                    firstValue.innerHTML = targetSpeed[1]
                    secondValue.innerHTML = targetSpeed[0]
                    thirdValue.innerHTML = ""
                    break;
                case 3:
                    firstValue.innerHTML = targetSpeed[2]
                    secondValue.innerHTML = targetSpeed[1]
                    thirdValue.innerHTML = targetSpeed[0]
                    break;
                default:
            }
            break;

        case "fastSpeed":

            let fastSection = document.querySelector("#center");
            let firstValue3 = fastSection.querySelector("#first");
            let secondValue3 = fastSection.querySelector("#second");
            let thirdValue3 = fastSection.querySelector("#third");

            if (!e.data.value) {
                firstValue3.innerHTML = ""
                secondValue3.innerHTML = ""
                thirdValue3.innerHTML = ""
                return
            }

            let fastSpeed = String(e.data.value)

            switch(fastSpeed.length) {
                case 1:
                    firstValue3.innerHTML = fastSpeed[0]
                    secondValue3.innerHTML = ""
                    thirdValue3.innerHTML = ""
                    break;
                case 2:
                    firstValue3.innerHTML = fastSpeed[1]
                    secondValue3.innerHTML = fastSpeed[0]
                    thirdValue3.innerHTML = ""
                    break;
                case 3:
                    firstValue3.innerHTML = fastSpeed[2]
                    secondValue3.innerHTML = fastSpeed[1]
                    thirdValue3.innerHTML = fastSpeed[0]
                    break;
                default:
            }
            break;

        case "patrolSpeed":
            let patrolSection = document.querySelector("#right")
            let firstValue2 = patrolSection.querySelector("#first");
            let secondValue2 = patrolSection.querySelector("#second");
            let thirdValue2 = patrolSection.querySelector("#third");

            if (!e.data.value) {
                firstValue2.innerHTML = ""
                secondValue2.innerHTML = ""
                thirdValue2.innerHTML = ""
                return
            }

            let patrolSpeed = String(e.data.value)

            switch(patrolSpeed.length) {
                case 1:
                    firstValue2.innerHTML = patrolSpeed[0]
                    secondValue2.innerHTML = ""
                    thirdValue2.innerHTML = ""
                    break;
                case 2:
                    firstValue2.innerHTML = patrolSpeed[1]
                    secondValue2.innerHTML = patrolSpeed[0]
                    thirdValue2.innerHTML = ""
                    break;
                case 3:
                    firstValue2.innerHTML = patrolSpeed[2]
                    secondValue2.innerHTML = patrolSpeed[1]
                    thirdValue2.innerHTML = patrolSpeed[0]
                    break;
                default:
            }
            break;

        case "extraText":
            if (e.data.value == "front") {
                let selectedDir = document.getElementById("front")
                let oppositeDir = document.getElementById("rear")
                selectedDir.style.color = "#FD5A15";
                selectedDir.style.textShadow = "0 0 10px #FD5A15";
                //
                oppositeDir.style.color = "";
                oppositeDir.style.textShadow = "";
            } else if (e.data.value == "rear") {
                let selectedDir = document.getElementById("rear")
                let oppositeDir = document.getElementById("front")
                selectedDir.style.color = "#00ffaa";
                selectedDir.style.textShadow = "0 0 10px #00ffaa";
                //
                oppositeDir.style.color = "";
                oppositeDir.style.textShadow = "";
            } else if (e.data.value == "fast") {
                let fastSec = document.getElementById("fast")
                if (e.data.value2) {
                    fastSec.style.color = "#FF0008";
                    fastSec.style.textShadow = "0 0 10px #FF0008";
                } else {
                    fastSec.style.color = "";
                    fastSec.style.textShadow = "";
                }
                // Tyhjennä
                let fastSection = document.querySelector("#center");
                let firstValue = fastSection.querySelector("#first");
                let secondValue = fastSection.querySelector("#second");
                let thirdValue = fastSection.querySelector("#third");

                firstValue.innerHTML = ""
                secondValue.innerHTML = ""
                thirdValue.innerHTML = ""
            }

        default:
    }
})