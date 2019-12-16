using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CharacterInitializer : MonoBehaviour {

    [SerializeField]
    SkinnedMeshRenderer rendererComponent;

    [SerializeField]
    SkinnedMeshRenderer hairRendererComponent;

    [SerializeField]
    Color[] hairColors;

    [SerializeField]
    Color[] shoeColors;

    [SerializeField]
    Color[] pantsColors;

    [SerializeField]
    Color[] shirtColors;

    [SerializeField]
    Color[] skinColors;

    [SerializeField]
    Vector2 shoeLength;

    [SerializeField]
    Vector2 pantsLength;

    [SerializeField]
    Vector2 shirtLength;

    void Start () {
        GenerateInstance ();
    }

    public void GenerateInstance () {

        int blendshapeCount = rendererComponent.sharedMesh.blendShapeCount;
        for (int i = 0; i < blendshapeCount; i++) {
            rendererComponent.SetBlendShapeWeight (i, Random.Range (0.0f, 100f));
        }

        int hairShapeCount = hairRendererComponent.sharedMesh.blendShapeCount;
        for (int i = 0; i < hairShapeCount; i++) {
            if (Random.Range (0, 2) == 0) {
                hairRendererComponent.SetBlendShapeWeight (i, Random.Range (0.0f, 100f));
            }
        }

        rendererComponent.material.SetColor ("_SkinColor", skinColors[Random.Range (0, skinColors.Length)]);

        hairRendererComponent.material.SetColor ("_HairColor", hairColors[Random.Range (0, hairColors.Length)]);

        rendererComponent.material.SetColor ("_ShoesColor", shoeColors[Random.Range (0, shoeColors.Length)]);
        rendererComponent.material.SetColor ("_PantsColor", pantsColors[Random.Range (0, pantsColors.Length)]);
        rendererComponent.material.SetColor ("_ShirtColor", shirtColors[Random.Range (0, shirtColors.Length)]);

        rendererComponent.material.SetFloat ("_ShoesLength", Random.Range (shoeLength.x, shoeLength.y));
        rendererComponent.material.SetFloat ("_PantsLength", Random.Range (pantsLength.x, pantsLength.y));
        rendererComponent.material.SetFloat ("_ShirtLength", Random.Range (shirtLength.x, shirtLength.y));
    }

}