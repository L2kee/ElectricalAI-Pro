from fastapi.testclient import TestClient

from backend.api.server import app

client = TestClient(app)


def test_health():
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json()["status"] == "ok"


def test_ohms_law_ok():
    response = client.post("/ohms-law", json={"voltage": 120, "resistance": 12})
    assert response.status_code == 200
    assert response.json()["current"] == 10


def test_ohms_law_bad_input():
    response = client.post("/ohms-law", json={"voltage": 120})
    assert response.status_code == 400
    assert "error" in response.json()


def test_voltage_drop_requires_new_fields():
    response = client.post("/voltage-drop", json={"current": 16, "resistance": 0.2})
    assert response.status_code == 422


def test_voltage_drop_ok():
    response = client.post(
        "/voltage-drop",
        json={
            "current": 16,
            "wire_size": "12 AWG",
            "length_ft": 75,
            "material": "copper",
            "voltage": 120,
            "phase": "single",
        },
    )
    assert response.status_code == 200
    body = response.json()
    assert body["voltage_drop"] == 4.63


def test_box_fill_ok():
    response = client.post(
        "/box-fill",
        json={
            "box_volume": 18,
            "conductor_size": "12 AWG",
            "conductor_count": 4,
            "device_count": 1,
            "clamp_count": 1,
            "equipment_ground_count": 1,
        },
    )
    assert response.status_code == 200
    assert response.json()["box_is_large_enough"] is True


def test_motor_flc_ok():
    response = client.post(
        "/motor-flc",
        json={"horsepower": "10", "voltage": "230", "phase": "three"},
    )
    assert response.status_code == 200
    assert response.json()["full_load_current"] == 28.0


def test_motor_flc_bad_input():
    response = client.post(
        "/motor-flc",
        json={"horsepower": "10", "voltage": "120", "phase": "three"},
    )
    assert response.status_code == 400
    assert "error" in response.json()


def test_transformer_sizing_ok():
    response = client.post(
        "/transformer-sizing",
        json={"kva": 75, "primary_voltage": 480, "secondary_voltage": 208, "phase": "three"},
    )
    assert response.status_code == 200
    assert response.json()["secondary_fla"] == 208.19


def test_transformer_sizing_bad_input():
    response = client.post(
        "/transformer-sizing",
        json={"kva": 0, "primary_voltage": 480, "secondary_voltage": 208, "phase": "three"},
    )
    assert response.status_code == 422


def test_unit_conversion_ok():
    response = client.post(
        "/unit-conversion",
        json={"category": "length", "from_unit": "ft", "to_unit": "m", "value": 100},
    )
    assert response.status_code == 200
    assert response.json()["result"] == 30.48


def test_unit_conversion_bad_input():
    response = client.post(
        "/unit-conversion",
        json={"category": "mass", "from_unit": "kg", "to_unit": "lb", "value": 1},
    )
    assert response.status_code == 400
    assert "error" in response.json()


def test_voltage_drop_comparison_ok():
    response = client.post(
        "/voltage-drop-comparison",
        json={"current": 16, "length_ft": 75, "material": "copper", "voltage": 120, "phase": "single"},
    )
    assert response.status_code == 200
    body = response.json()
    assert body["smallest_size_within_3_percent"] == "10 AWG"
    assert len(body["results"]) == 18


def test_voltage_drop_comparison_bad_input():
    response = client.post(
        "/voltage-drop-comparison",
        json={"current": 0, "length_ft": 75},
    )
    assert response.status_code == 422
