using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ClickClose : MonoBehaviour {

    void OnMouseDown () {
        Application.Quit ();
    }
}