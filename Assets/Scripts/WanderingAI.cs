using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.AI;

public class WanderingAI : MonoBehaviour {

    NavMeshAgent agent;
    [SerializeField]
    Animator animator;

    void Start () {
        agent = GetComponent<NavMeshAgent> ();
        InvokeRepeating ("Wander", Random.Range (0.0f, 2f), Random.Range (3f, 12f));
    }

    void Wander () {
        float range = Random.Range (2f, 6f);
        Vector3 randomDirection = Random.insideUnitSphere * range;
        randomDirection += transform.position;
        NavMeshHit hit;
        Vector3 finalPosition = Vector3.zero;
        if (NavMesh.SamplePosition (randomDirection, out hit, range, 1)) {
            agent.destination = hit.position;
        }
    }

    void Update () {
        Vector3 relativeVelocity = transform.InverseTransformDirection (agent.velocity);
        if (relativeVelocity.magnitude > 0.1f) {
            animator.SetFloat ("velX", relativeVelocity.x);
            animator.SetFloat ("velY", relativeVelocity.z);
        }

    }
}