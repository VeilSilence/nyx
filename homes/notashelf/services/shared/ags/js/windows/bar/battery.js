import { Widget, Battery } from "../../imports.js";
const { Box, Button, Revealer, Label } = Widget;

const BatIcon = () =>
    Label({
        className: "batIcon",
        connections: [
            [
                Battery,
                (icon) => {
                    icon.toggleClassName("charging", Battery.charging);
                    icon.toggleClassName("charged", Battery.charged);
                    icon.toggleClassName("low", Battery.percent < 30);
                },
            ],
            [
                Battery,
                (self) => {
                    if (!Battery.available) {
                        // avoid unnnecessary assignments
                        return;
                    }

                    const icons = [
                        ["󰂎", "󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"],
                        ["󰢟", "󰢜", "󰂆", "󰂇", "󰂈", "󰢝", "󰂉", "󰢞", "󰂊", "󰂋", "󰂅"],
                    ];

                    const chargingIndex = Battery.charging ? 1 : 0;
                    const percentIndex = Math.floor(Battery.percent / 10);
                    self.label = icons[chargingIndex][percentIndex].toString();
                    self.tooltipText = `${Math.floor(Battery.percent)}%`;
                },
            ],
        ],
    });
const PercentLabel = () =>
    Revealer({
        transition: "slide_down",
        revealChild: false,
        child: Label({
            className: "batPercent",
            connections: [
                [
                    Battery,
                    (self) => {
                        self.label = `${Battery.percent}%`;
                    },
                ],
            ],
        }),
    });

const percentLabelInstance = PercentLabel();

export const BatteryWidgetOld = () =>
    Button({
        className: "battery",
        onHover: () => (percentLabelInstance.revealChild = true),
        onHoverLost: () => (percentLabelInstance.revealChild = false),
        binds: [["visible", Battery, "available"]],
        child: BatIcon(),
    });

export const BatteryWidget = () =>
    Box({
        className: "battery",
        cursor: "pointer",
        child: BatIcon(),
        binds: [["visible", Battery, "available"]],
    });
