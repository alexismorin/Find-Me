using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class Generator : MonoBehaviour {

    [SerializeField]
    GameObject[] props;

    [SerializeField]
    GameObject[] grasses;

    [SerializeField]
    GameObject tent;

    [SerializeField]
    GameObject character;

    [SerializeField]
    int numberOfProps = 20;

    [SerializeField]
    Collider gameArea;

    [SerializeField]
    LayerMask mask;

    [SerializeField]
    Transform characterPreviewPosition;

    [SerializeField]
    GameObject canvas;

    GameObject findMeInstance;

    void Start () {
        var bounds = gameArea.bounds;
        GameObject findMe = null;

        for (int i = 0; i < numberOfProps; i++) {
            Vector3 randomPos = new Vector3 (Random.Range (bounds.min.x, bounds.max.x), 0f, Random.Range (bounds.min.z, bounds.max.z));
            Vector3 randomEuler = new Vector3 (0f, Random.Range (0f, 360f), 0f);

            GameObject instance = Instantiate (props[Random.Range (0, props.Length)], randomPos, Quaternion.Euler (randomEuler));
        }

        for (int i = 0; i < numberOfProps * 2; i++) {
            Vector3 randomPos = new Vector3 (Random.Range (bounds.min.x, bounds.max.x), 0f, Random.Range (bounds.min.z, bounds.max.z));
            Vector3 randomEuler = new Vector3 (0f, Random.Range (0f, 360f), 0f);

            GameObject instance = Instantiate (grasses[Random.Range (0, grasses.Length)], randomPos, Quaternion.Euler (randomEuler));
            instance.transform.localScale *= Random.Range (1f, 2f);
        }

        Vector3 randomTentPos = new Vector3 (Random.Range (bounds.min.x, bounds.max.x), 0f, Random.Range (bounds.min.z, bounds.max.z));
        Vector3 randomTentEuler = new Vector3 (0f, Random.Range (0f, 360f), 0f);
        GameObject tentInstance = Instantiate (tent, randomTentPos, Quaternion.Euler (randomTentEuler));

        for (int i = 0; i < numberOfProps * 8; i++) {
            Vector3 characterPos = new Vector3 (Random.Range (bounds.min.x, bounds.max.x), 0f, Random.Range (bounds.min.z, bounds.max.z));
            Vector3 characterEuler = new Vector3 (0f, Random.Range (0f, 360f), 0f);

            RaycastHit hit;
            Debug.DrawRay (characterPos + Vector3.up, Vector3.down, Color.green);
            if (Physics.Raycast (characterPos + Vector3.up, Vector3.down, out hit, 100.0f, mask)) {
                GameObject instance = Instantiate (character, characterPos, Quaternion.Euler (characterEuler));
                findMe = instance;
                print (findMe.name);
            }

        }

        findMe.GetComponent<CharacterInitializer> ().GenerateInstance ();
        findMe.GetComponent<CharacterInitializer> ().enabled = false;
        findMe.GetComponent<WanderingAI> ().enabled = false;
        findMe.GetComponent<NavMeshAgent> ().enabled = false;

        findMeInstance = Instantiate (findMe, characterPreviewPosition.position, characterPreviewPosition.rotation);
        findMeInstance.transform.localScale = characterPreviewPosition.localScale;

        findMeInstance.layer = LayerMask.NameToLayer ("Character");
        Renderer[] renderers = GetComponentsInChildren<Renderer> ();
        foreach (Renderer renderer in renderers) {
            renderer.gameObject.layer = LayerMask.NameToLayer ("Character");
        }

        findMe.GetComponent<NavMeshAgent> ().enabled = true;
        findMe.GetComponent<WanderingAI> ().enabled = true;
        findMe.AddComponent<ClickClose> ();
        Invoke ("StartGame", 6f);

    }

    void StartGame () {

        Destroy (canvas);
        Destroy (findMeInstance);
    }
}